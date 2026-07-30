import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark import SparkContext
from pyspark.sql import functions as F
from awsglue.dynamicframe import DynamicFrame
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
formater = logging.Formatter(
    '%(asctime)s - %(levelname)s - %(message)s'
)
handler.setFormatter(formater)
logger.addHandler(handler)


args = getResolvedOptions(sys.argv, [
    "JOB_NAME"
])
sc          = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark       = glueContext.spark_session
job         = Job(glueContext)

job.init(args["JOB_NAME"], args)


TABLES  = ["events", "sessions", "user_signups"]
tablas  = {}
for tables in TABLES:
    dyf = glueContext.create_dynamic_frame.from_catalog(
        database   = "database-silver",
        table_name = tables
    )
    df = dyf.toDf()
    tablas[tables] = df
    df.createOrReplaceTempView(tables)

# porcentaje de usuarios que se registran, pero no inician session aun.
def porcentaje_login_user():
    query_pct_user_sin_session = """
        ---porcentaje de usuarios registrados pero que no han iniciado session
        with conteo_sessiones as (
            select 
            -- contar usuarios sin sessiones
            count(case when s.session_user_id is null then us.user_id end) as sin_sessiones,
            -- cantidad de registros
            count(us.user_id) as total_registrados 
            from user_signups us
            left join sessions s on us.user_id = s.session_user_id
        )
        select 
            u.sin_sessiones,
            u.total_registrados,
            round((u.sin_sessiones * 100.0 / u.total_registrados), 2) as pct_user_sin_sessiones
        from conteo_sessiones u
    """
    return spark.sql(query_pct_user_sin_session)
    

TABLAS_GOLD = {
    "pct_usuarios_sin_session": porcentaje_login_user
}

erros_tables       = []
successfuly_tables = []
for tabla_gold, function in TABLAS_GOLD.items():
    try:
        df_gold = function()
        #convertimos a dynamicFrame
        dyf  = DynamicFrame.fromDF(df_gold, glueContext, "dyf_gold")
        sink = glueContext.getSink(
            connection_type     = "s3",
            path                = f"s3://gld-logs-ecommerce/{tabla_gold}/",
            enableUpdateCatalog = True,
            compression         = "snappy",
            UpdateBehavior      = "UPDATE_IN_DATABASE",
            partitionKeys       = ["year", "month", "day"],
            transformation_ctx  = f"write_gold_{tabla_gold}"
        )
        sink.setFormat("glueparquet")
        sink.setCatalogInfo(
            catalogDatabase  = "database-gold",
            catalogTableName = tabla_gold
        )
        sink.writeFrame(dyf)
        
        
        successfuly_tables.append(tabla_gold)
    except Exception as ex:
        erros_tables.append({
            "table": tabla_gold,
            "error": str(ex)
        })
        logger.error(f"Table: {tabla_gold} Fallo: {str(ex)}", exc_info=True)
        continue

logger.info("Capa Gold Procesado Correctamente")
logger.info(f"Tablas Completadas: {successfuly_tables}")

if erros_tables:
    logger.error(f"Tablas que No se completaron: {erros_tables}")
        
job.commit()