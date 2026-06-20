import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark import SparkContext
from awsglue.job import Job
from pyspark.sql.types import StringType, IntegerType, DoubleType, FloatType, TimestampType, DecimalType, StructField
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import functions as F

args = getResolvedOptions(sys.argv, [
    "JOB_NAME",
    "DATABASE"
])

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

job.init(args["JOB_NAME"], args)



def fillna_columns(dyf: F.DataFrame) -> F.DataFrame:
    fill_int = [column.name for column in dyf.schema if isinstance(column.dataType, (IntegerType, DoubleType, DecimalType))]
    
    fill_str = [column.name for column in dyf.schema if isinstance(column.dataType, (StringType))]
    
    fill_values = {col: 0 for col in fill_int}
    fill_values.update({col: "unknown" for col in fill_str})
    
    df = df.fillna(fill_values)
    
    return df

def num_positivos(dyf: F.DataFrame)-> F.DataFrame:
    for columns in dyf.schema:
        if isinstance(columns.dataType, (IntegerType, FloatType, DecimalType)):
            df = dyf.withColumn(
                columns.name,
                F.abs(F.col(columns.name))
            )

    return df

def flatten_columns(dyf: F.DataFrame)-> F.DataFrame:
    columns_flatten = []
    for col in dyf.schema.fields:
        if isinstance(col.dataType, StructField):
            for sub_col in col.dataType.fields:
                columns_flatten.append(F.col(f"{col.name}.{sub_col.name}").alias(sub_col.name))
        else:
            columns_flatten.append(F.col(col.name))
    
    df = dyf.select(columns_flatten)
    
    return df
                


TABLES = ["api_request_logs", "inventory_movement_logs", "order_processing_logs", "payment_transaction_logs", "user_session_logs"]

for tables in TABLES:
    dyf = glueContext.create_dynamic_frame.from_catalog(
        database=args["JOB_NAME"],
        table_name=tables,
        transformation_ctx=f"slv_{tables}"
    )
    # convertir dinamicframe a dataFrame
    df = dyf.toDF()
    
    # aplanar Datos
    df = flatten_columns(df)
    
    # Rellenar Datos Nulos
    df = fillna_columns(df)
    
    # Cambiar valores Negativos a Positivos
    df = num_positivos(df)
    df.printSchema()