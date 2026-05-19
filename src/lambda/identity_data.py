import boto3
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

def parts_date():
   zona_colombia = ZoneInfo("America/Bogota")
   fecha = datetime.now(zona_colombia)
   
   fecha_procesar = fecha - timedelta(days=1)
   return fecha_procesar

def lambda_handler(event, context):
   date = parts_date()
   try:
        s3 = boto3.client("s3")
        hay_datos = False
        bucket_name = "brz-logs-ecommerce"
        tables = [
            "inventory_logs",
            "order_logs",
            "payment_logs",
            "system_error_logs",
            "user_activity_logs"
        ]
        
        for tab in tables:
            path_prefix = f"{tab}/year=2026/month=05/day=16/"
            res = s3.list_objects_v2(Bucket=bucket_name, Prefix=path_prefix)
            
            if "Contents" in res:
                hay_datos = True
                print("Datos del dia tal encontrados")
            else:
                print("no hay datos del dia tal")
        
        return hay_datos
            
                
            
            
   except Exception as ex:
      print(f"ERROR EN LA LAMBDA DE IDENNTIFICACION: {ex}")
      
      
if __name__ == "__main__":
   lambda_handler({}, None)