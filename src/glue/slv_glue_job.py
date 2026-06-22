import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark import SparkContext
from awsglue.job import Job
from pyspark.sql.types import StringType, IntegerType, DoubleType, FloatType, TimestampType, DecimalType, StructType, LongType
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import functions as F

args = getResolvedOptions(sys.argv, [
    "JOB_NAME"
])

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

job.init(args["JOB_NAME"], args)
NEW_SCHEMA_CONFIG = {
    "api_request_logs": {
        "request_id": StringType(),
        "http_status": IntegerType(),
        "request_bytes": DoubleType(),
        "response_bytes": DoubleType(),
        "inserted_at": TimestampType()
    },
    "inventory_movement_logs": {
        "event_id": StringType(),
        "new_price": DecimalType(),
        "previous_price": DecimalType(),
        "new_quantity": IntegerType(),
        "previous_quantity": IntegerType(),
        "quantity_change": IntegerType(),
        "inserted_at": TimestampType()
    },
    "order_processing_logs": {
        "event_id": StringType(),
        "items_count": IntegerType(),
        "total": DecimalType(),
        "processing_time_ms": LongType(),
        "inserted_at": TimestampType()
    },
    "payment_transaction_logs": {
        "event_id": StringType(),
        "installments": IntegerType(),
        "value": DecimalType(),
        "bin": IntegerType(),
        "last_four": IntegerType(),
        "processing_time_ms": LongType(),
        "retry_count": IntegerType(),
        "score": IntegerType(),
        "inserted_at": TimestampType()
        
    },
    "user_session_logs": {
        "event_id": StringType(),
        "cart_items_count": IntegerType(),
        "inserted_at": TimestampType()
    }
    
}

def fillna_columns(dyf: F.DataFrame) -> F.DataFrame:
    fill_int = [column.name for column in dyf.schema if isinstance(column.dataType, (IntegerType, DoubleType, DecimalType, LongType))]
    
    fill_str = [column.name for column in dyf.schema if isinstance(column.dataType, (StringType))]
    
    fill_values = {col: 0 for col in fill_int}
    fill_values.update({col: "unknown" for col in fill_str})
    
    df = dyf.fillna(fill_values)
    
    return df

def num_positivos(dyf: F.DataFrame)-> F.DataFrame:
    for columns in dyf.schema:
        if isinstance(columns.dataType, (IntegerType, FloatType, DecimalType, LongType)):
            df = dyf.withColumn(
                columns.name,
                F.abs(F.col(columns.name))
            )

    return df

def flatten_columns(dyf: F.DataFrame)-> F.DataFrame:
    columns_flatten = []
    for col in dyf.schema.fields:
        if isinstance(col.dataType, StructType):
            for sub_col in col.dataType.fields:
                columns_flatten.append(F.col(f"{col.name}.{sub_col.name}").alias(sub_col.name))
        else:
            columns_flatten.append(F.col(col.name))
    
    df = dyf.select(columns_flatten)
    
    return df

def convert_type_data(dyf: F.DataFrame, table_name: str) -> F.DataFrame:
    if table_name not in NEW_SCHEMA_CONFIG:
        return dyf
    
    new_schema = NEW_SCHEMA_CONFIG[table_name]
    new_columns = []
    
    for field in dyf.schema.fields:
        columns_name = field.name
        
        if columns_name in new_schema:
            tipo_final = new_schema[columns_name]
            new_columns.append(F.col(columns_name).cast(tipo_final).alias(columns_name))
        else:
            new_columns.append(F.col(columns_name))
            
    df = dyf.select(new_columns)
    return df


def drop_duplicates(dyf: F.DataFrame, table_name: str) -> F.DataFrame:
    if table_name not in NEW_SCHEMA_CONFIG:
        return dyf
    
    df = dyf
    table_config = NEW_SCHEMA_CONFIG[table_name]
    if "id" in table_config:
        pk_column = table_config["id"]
        if pk_column in dyf.columns:
            df = df.filter(F.col(pk_column).isNotNull()).dropDuplicates(subset=[pk_column])
    
    return df

TABLES = ["api_request_logs", "inventory_movement_logs", "order_processing_logs", "payment_transaction_logs", "user_session_logs"]
for tables in TABLES:
    dyf = glueContext.create_dynamic_frame.from_catalog(
        database="database-bronze",
        table_name=tables,
        transformation_ctx=f"read_bronze"
    )
    # convertir dinamicframe a dataFrame
    df = dyf.toDF()

    # Aplanar Datos
    df = flatten_columns(df)
    
    # Cambiar Tipos de Datos
    df = convert_type_data(df, tables)
    
    # Eliminar Duplicados
    df = drop_duplicates(df, tables)
    
    # Rellenar Datos Nulos
    df = fillna_columns(df)
    
    dyf = DynamicFrame.fromDF(df, glueContext, "dyf_end")
    
    sink = glueContext.getSink(
        connection_type="s3",
        path = f"s3://slv-logs-ecommerce/{tables}/",
        enableUpdateCatalog=True,
        compression="snappy",
        updateBehavior="UPDATE_IN_DATABASE",
        partitionKeys=["year", "month", "day"],
        transformation_ctx="write_silver"

    )
    sink.setFormat("glueparquet")
    sink.setCatalogInfo(catalogDatabase="database-silver", catalogTableName=tables)
    sink.writeFrame(dyf)
    
    