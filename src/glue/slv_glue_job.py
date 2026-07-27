import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark import SparkContext
from awsglue.job import Job
from pyspark.sql.types import StringType, IntegerType, DoubleType, FloatType, TimestampType, DateType,DecimalType, StructType, LongType
from pyspark.sql.window import Window
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import functions as F
import logging
from datetime import datetime, timedelta

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
    "events": {
        "id": "event_id",
        "duration_seconds": IntegerType(),
        "response_time_ms": IntegerType(),
        "created_at": TimestampType(),
        "updated_at": TimestampType(),
        "dedup"  : "updated_at"
    },
    "sessions": {
        "id":"session_id",
        "duration_seconds": IntegerType(),
        "pages_viewed": IntegerType(),
        "started_at": TimestampType(),
        "updated_at": TimestampType(),
        "dedup": "updated_at"
    },
    "user_signups": {
        "id":"user_id",
        "created_at": TimestampType(),
        "updated_at": TimestampType(),
        "dedup": "updated_at"
    }
}

def fillna_columns(dyf: F.DataFrame) -> F.DataFrame:
    fill_int    =  [column.name for column in dyf.schema if isinstance(column.dataType, (IntegerType, DoubleType, DecimalType, LongType))]
    fill_date   =  [column.name for column in dyf.schema if isinstance(column.dataType, (DateType, TimestampType))]
    fill_str    =  [column.name for column in dyf.schema if isinstance(column.dataType, (StringType))]
    
    ayer_string = (datetime.combine(datetime.today() - timedelta(days=1), datetime.min.time())).strftime("%Y-%m-%d %H:%M:%S")    
    
    
    fill_values = {col: 0 for col in fill_int}
    fill_values.update({("unknown" if col == "/" else col): "unknown" for col in fill_str})
    fill_values.update({col: ayer_string for col in fill_date})
    
    df = dyf.fillna(fill_values)    
    df = df.replace("/", "unknown", subset=fill_str)
    
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

def mayus_min(dyf: F.DataFrame) -> F.DataFrame:
    df = dyf
    for field in dyf.schema:
        if isinstance(field.dataType, (StringType)):
            df = df.withColumn(field.name, F.initcap(field.name))

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
    
    df = dyf
    new_schema = NEW_SCHEMA_CONFIG[table_name]
    new_columns = []
    
    for field in df.schema.fields:
        columns_name = field.name
        
        if columns_name in new_schema:
            tipo_final = new_schema[columns_name]
            new_columns.append(F.col(columns_name).cast(tipo_final).alias(columns_name))
        else:
            new_columns.append(F.col(columns_name))
            
    df = df.select(new_columns)
    return df


def drop_duplicates(dyf: F.DataFrame, table_name: str) -> F.DataFrame:
    if table_name not in NEW_SCHEMA_CONFIG:
        return dyf
    
    df = dyf
    table_config = NEW_SCHEMA_CONFIG[table_name]
    if "id" in table_config:
        pk_column = table_config["id"]
        dedup = table_config["dedup"]
        if pk_column in dyf.columns and dedup in dyf.columns:
            #agrupamos todos los duplicados aparate y los ordenamos de mayor a menor
            window_dedup = Window.partitionBy(pk_column).orderBy(F.col(dedup).desc())
            # creamos una columna auxiliar para rankear los duplicados
            window_ranked = df.withColumn("rn", F.row_number().over(window_dedup))
            # filtramos los duplicados por el 1 ya que es el ultimo
            df_window = window_ranked.filter(F.col("rn") == 1)
            # eliminamos esa columna axuliar y quedamos con el ultimo registro
            df = df_window.drop("rn")
    
    return df



TABLES = ["events", "sessions", "user_signups"]
failed_table = []
succesfuly_table = []

for tables in TABLES:
    try:  
        dyf = glueContext.create_dynamic_frame.from_catalog(
            database="database-bronze",
            table_name=tables,
            transformation_ctx=f"read_bronze_{tables}"
        )
        # convertir dinamicframe a dataFrame
        logger.info(f"Procesando Tabla: {tables}")
        df = dyf.toDF()

        # Aplanar Datos
        df = flatten_columns(df)
        
        # Rellenar Datos Nulos (antes de cast para evitar tipos mixtos)
        df = fillna_columns(df)
        
        # Cambiar Tipos de Datos
        df = convert_type_data(df, tables)
        
        # pasar numeros negativos a positivos
        df = num_positivos(df)
        
        # Capitalizar los tipos de datos string
        df = mayus_min(df)
        
        # Eliminar Duplicados
        df = drop_duplicates(df, tables)
        
        dyf = DynamicFrame.fromDF(df, glueContext, "dyf_end")
        
        sink = glueContext.getSink(
            connection_type="s3",
            path = f"s3://slv-logs-ecommerce/{tables}/",
            enableUpdateCatalog=True,
            compression="snappy",
            updateBehavior="UPDATE_IN_DATABASE",
            partitionKeys=["year", "month", "day"],
            transformation_ctx=f"write_silver_{tables}"
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

job.commit()