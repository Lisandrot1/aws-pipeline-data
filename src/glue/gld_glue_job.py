import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark import SparkContext
from pyspark.sql import functions as F
from awsglue.dynamicframe import DynamicFrame

args = getResolvedOptions(sys.argv, [
    "JOB_NAME"
])
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark =glueContext.spark_session
job = Job(glueContext)

job.init(args["JOB_NAME"], args)

job.commit()