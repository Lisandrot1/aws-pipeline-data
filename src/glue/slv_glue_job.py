import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark import SparkContext
from awsglue.job import Job
from pyspark.sql.types import StringType, IntegerType, DoubleType, DateType, FloatType, TimestampType
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


TABLES = ["inventory_logs", "order_logs", "payment_logs", "user_activity_logs", "error_system_logs"]
frames = {}
for tables in TABLES:
    frames[tables] = glueContext.create_dynamic_frame.from_catalog(
        database=args["DATABASE"],
        table_name=tables,
        transformation_ctx="slv_job"
    )

def slv_inventory(dyf: F.DataFrame) -> F.DataFrame:
    df = dyf.toDF()
    df = df.select([
        F.col("event_id"),
        F.col("actor.id").alias("actor_id"),
        F.col("actor.role").alias("actor_role"),
        F.coalesce(
            F.col("details.change_delta.int"),
            F.col("details.change_delta.double")).cast(IntegerType()).alias("change_delta"),
        F.coalesce(
            F.col("details.new_value.int"),
            F.col("details.new_value.double")).cast(IntegerType()).alias("new_value"),
        F.coalesce(
            F.col("details.previous_value.int"),
            F.col("details.previous_value.double")).cast(IntegerType()).alias("previous_value"),
        F.col("details.product_id").alias("product_id"),
        F.col("details.unit").alias("unit"),
        F.col("event_type"),
        F.col("level"),
        F.col("metadata.reason").alias("reason"),
        F.col("metadata.section").alias("section"),
        F.col("metadata.warehouse_id").alias("warehouse_id"),
        F.col("service"),
        F.col("at").cast(DateType()).alias("date_event")
    ])
    
    df = df.filter(F.col("event_id").isNotNull()).dropDuplicates(subset=["event_id"])
    
    for columns in df.schema:
        if isinstance(columns.dataType, (IntegerType, FloatType, DoubleType)):
            df = df.withColumn(
                columns.name,
                F.when(F.col(columns.name) < 0, F.abs(F.col(columns.name)))
                .otherwise(F.col(columns.name))
            )
    
    fill_integer = [col.name for col in df.schema if isinstance(df.dataType, (IntegerType, FloatType, DoubleType))]
    fill_string = [col.name for col in df.schema if isinstance(df.dataType, (StringType))]
    
    fill_values = {col: 0 for col in fill_integer}
    fill_values.update({col: "UNKNOWN" for col in fill_string})
    
    df = df.fillna(fill_values)
    return df



def slv_orders(dyf: F.DataFrame) -> F.DataFrame:
    df = dyf.toDF()
    df = df.select(
        F.col("event_id"),
        F.col("actor.id").alias("actor_id"),
        F.col("actor.role").alias("actor_role"),
        F.col("details.estimated_delivery_at").cast(TimestampType()).alias('estimated_delivery_at'),
        F.col("details.items_count").cast(IntegerType()).alias("items_count"),
        F.col("details.order_id").alias("order_id"),
        F.col("details.shipping_method").alias("shipping_method"),
        F.col("details.total_weight").cast(DoubleType()).alias("total_weight"),
        F.col("event_type"),
        F.col("level"),
        F.col("metadata.priority").alias("priority"),
        F.col("metadata.region").alias("region"),
        F.col("metadata.source").alias("source"),
        F.col("metadata.warehouse_id").alias("warehouse_id"),
        F.col("service"),
        F.col("at").cast(TimestampType()).alias("event_date")
    )
    df = df.filter(F.col("event_id").isNotNull()).dropDuplicates(subset=["event_id"])
    
    # negativos
    for columns in df.schema:
        if isinstance(columns.dataType, (FloatType, IntegerType, DoubleType)):
            df = df.withColumn(
                columns.name,
                F.when(F.col(columns.name) < 0, F.abs(F.col(columns.name)))
                .otherwise(F.col(columns.name))
            
            )
    fill_int = [col.name for col in df.schema if isinstance(col.dataType, (IntegerType, FloatType, DoubleType))]
    fill_str = [col.name for col in df.schema if isinstance(col.dataType, (StringType))]
    
    fill_values = {col: 0 for col in fill_int}
    fill_values.update({col: "UNKNOWN" for col in fill_str})
    
    df = df.fillna(fill_values)
    print(df)
    return df

def slv_payments(dyf: F.DataFrame) -> F.DataFrame:
    df = dyf.toDF()
    return df
def slv_users(dyf: F.DataFrame) -> F.DataFrame:
    df = dyf.toDF()
    return df
def slv_sysrem(dyf: F.DataFrame) -> F.DataFrame:
    df = dyf.toDF()
    return df

df_inventory = slv_inventory(frames["inventory_logs"])
df_order = slv_orders(frames["order_logs"])
df_payments = slv_payments(frames["payment_logs"])
df_users = slv_users(frames["user_activity_logs"])
df_systems = slv_payments(frames["error_system_logs"])
