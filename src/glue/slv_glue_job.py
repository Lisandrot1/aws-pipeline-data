import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark import SparkContext
from awsglue.job import Job
from pyspark.sql.types import StringType, IntegerType, DoubleType, DateType
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import F

sc = SparkContext()
gluecontext = GlueContext(sc)
spark = gluecontext.spark_session
job = Job(gluecontext)
job.init()



df = gluecontext.create_dynamic_frame.from_catalog(
    database="",
    table_name=""
)


job.commit()