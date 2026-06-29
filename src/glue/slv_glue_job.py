import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark import SparkContext
from awsglue.job import Job
from pyspark.sql.types import StringType, IntegerType, DoubleType, FloatType, TimestampType, DecimalType, StructType, LongType
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import functions as F
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter(
    '%(asctime)s - %(levelname)s - %(message)s'
)
handler.setFormatter(formatter)
logger.addHandler(handler)


args = getResolvedOptions(sys.argv, [
    "JOB_NAME"
])

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

job.init(args["JOB_NAME"], args)
NEW_SCHEMA_CONFIG = {
    "api_logs": {
        "id": "api_log_id",
        "payload_size_bytes": IntegerType(),
        "body_size_bytes": IntegerType(),
        "latency_ms": IntegerType(),
        "timestamp": TimestampType()
    },
    "errors": {
        "id": "error_id",
        "timestamp": TimestampType()
    },
    "events": {
        "id": "event_id",
        "duration_ms": IntegerType(),
        "timestamp": TimestampType()
        
    },
    "sessions": {
        "id":"session_id",
        "duration_seconds": IntegerType(),
        "pages_visited": IntegerType(),
        "events_count": IntegerType(),
        "started_at": TimestampType(),
        "timestamp": TimestampType()
    },
    "user_signups": {
        "id":"signup_id",
        "created_at": TimestampType(),
        "abandoned_at_step": TimestampType()
        
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
    df = dyf
    for columns in dyf.schema:
        if isinstance(columns.dataType, (IntegerType, FloatType, DecimalType, LongType)):
            df = df.withColumn(
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

TABLES = ["api_logs", "errors", "events", "sessions", "user_signups"]
failed_table = []
succesfuly_table = []

for tables in TABLES:
    try:  
        dyf = glueContext.create_dynamic_frame.from_catalog(
            database="database-bronze",
            table_name=tables,
            transformation_ctx=f"read_bronze"
        )
        # convertir dinamicframe a dataFrame
        logger.info(f"Procesando Tabla: {tables}")
        df = dyf.toDF()

        # Aplanar Datos
        df = flatten_columns(df)
        
        # Cambiar Tipos de Datos
        df = convert_type_data(df, tables)
        
        # pasar numeros negativos a positivos
        df = num_positivos(df)
        
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
        
        succesfuly_table.append(tables)
    except Exception as ex:
        failed_table.append({
            "table": tables,
            "error": str(ex)
        })
        logger.error(f"Table: {tables} Fallo: {str(ex)}", exc_info=True)
        continue

logger.info("Procesamiento Finalizado")
logger.info(f"Tablas Completadas: {succesfuly_table}")

if failed_table:
    logger.error(f"Tablas con Error: {failed_table}")
