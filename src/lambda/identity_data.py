import boto3
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

def parts_date():
   zona_colombia = ZoneInfo("America/Bogota")
   fecha = datetime.now(zona_colombia)
   
   fecha_procesar = fecha - timedelta(days=1)
   return fecha_procesar

def lambda_handler(event, context):
   fecha = parts_date()
   try:
        s3 = boto3.client("s3")
        
        hay_datos = False
        bucket_name = "brz-logs-ecommerce"
        tables = [
            "api_logs",
            "errors",
            "events",
            "sessions",
            "user_signups"
        ]
        
        for tab in tables:
            path_prefix = f"{tab}/year={fecha.year}/month={fecha.month:02d}/day={fecha.day}/"
            res = s3.list_objects_v2(Bucket=bucket_name, Prefix=path_prefix)
            
            
            if "Contents" in res:
                hay_datos = True
                print(f"{hay_datos}: Datos del dia tal encontrados")
            else:
                print(f"no hay datos en: {tab} y dia: {fecha.day}")
        
        return {
            "continuar" : hay_datos
        }  
   except Exception as ex:
      print(f"ERROR EN LA LAMBDA DE IDENNTIFICACION: {ex}")
      
      
if __name__ == "__main__":
   lambda_handler({}, None)
