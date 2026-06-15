import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark import SparkContext
from awsglue.job import Job
from pyspark.sql.types import StringType, IntegerType, DoubleType, DateType
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
        table_name=tables
    )

def slv_inventory(dyf: F.DataFrame) -> F.DataFrame:
    df = dyf.toDF()
    return df
def slv_orders(dyf: F.DataFrame) -> F.DataFrame:
    df = dyf.toDF()
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
