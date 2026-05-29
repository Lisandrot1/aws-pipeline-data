#=============== VARIABLES GENERALES ===========================
#================== REGION ====================================
region        = "us-east-1"

#hola
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

# ====================================

#======================== VARIABLES BUCKETS BRONZE =================
bucket_bronze = "brz-logs-ecommerce"

tags_bronze = {
    Name       = "BUCKETS PIPELINE"
    Owner      = "TORRES IAM"
    Enviroment = "prod"
    Capa       = "Bronze"
}

lifecycle_bronze = {
  enable_lifecycle_rule                     = true
  transition_days_standard_ia               = 30
  transition_days_glacier                   = 60
  noncurrent_version_transition_days        = 1
  noncurrent_version_expiration_days        = 2
  enable_expired_object_delete_marker       = true
  enable_abort_incomplete_multipart_upload  = true
  abort_incomplete_multipart_upload_days    = 7
  enable_direct_glacier                     = false
  transition_days_glacier_direct            = 0
}

#==========================================================================
#====================== VARIABLES BUCKET SILVER ============================
bucket_silver = "slv-logs-ecommerce"

tags_silver = {
    Name       = "BUCKETS PIPELINE"
    Owner      = "TORRES IAM"
    Enviroment = "prod"
    Capa       = "Silver"
}

lifecycle_silver = {
  enable_lifecycle_rule                    = true
  transition_days_standard_ia              = 30
  transition_days_glacier                  = 60
  noncurrent_version_transition_days       = 1
  noncurrent_version_expiration_days       = 2
  enable_expired_object_delete_marker      = true
  enable_abort_incomplete_multipart_upload = true
  abort_incomplete_multipart_upload_days   = 7
  enable_direct_glacier                    = false
  transition_days_glacier_direct           = 0
}

#===============================================================================
#====================== VARIABLES BUCKET GOLD ===================================
bucket_gold   = "gld-logs-ecommerce"

tags_gold = {
    Name       = "BUCKETS PIPELINE"
    Owner      = "TORRES IAM"
    Enviroment = "prod"
    Capa       = "Gold"
}

lifecycle_gold = {
  enable_lifecycle_rule                    = true
  transition_days_standard_ia              = 30
  transition_days_glacier                  = 60
  noncurrent_version_transition_days       = 1
  noncurrent_version_expiration_days       = 2
  enable_expired_object_delete_marker      = true
  enable_abort_incomplete_multipart_upload = true
  abort_incomplete_multipart_upload_days   = 7
  enable_direct_glacier                    = true
  transition_days_glacier_direct           =  30
}

# ===============================================================
#============ VARIABLE NOMBRE ROLE CRAWLER ============================
name_role_crawler = "data-crawler-role"

db_catalog_bronze = "database-bronze"
db_catalog_silver = "database-silver"
db_catalog_gold = "database-gold"

tags_db_brz = {
  Name = "DB BRZ"
  Owner = "TORRES IAM"
  Capa = "Bronze"
}
tags_db_slv = {
  Name = "DB BRZ"
  Owner = "TORRES IAM"
  Capa = "Silver"
}
tags_db_gld = {
  Name = "DB BRZ"
  Owner = "TORRES IAM"
  Capa = "Gold"
}


crawler_silver = "crawler-identity-slv"
crawler_gold = "crawler-identity-gld"

path_bronze = [ "inventory_logs", "order_logs", "payment_logs", "system_error_logs", "user_activity_logs" ]

tags = {
  Name       = "Crawlers Identity"
  Owner      = "TORRES IAM"
  Enviroment = "prod"
  Capa       = "AWS Glue Crawler"
}
#============================================================================
#=====================VARIABLES LAMBDA=======================================
lambda_name = "identity-data-s3"
name_policy_lambda = "lectura-S3-ambda"
name_rol_lambda = "rol-read-lambda-s3"
lambda_tags = {
  Name       = "Lambda identity"
  Owner      = "TORRES IAM"
  Enviroment = "prod"
  Capa       = "Lambda"
}
#==============================================================================
#======================= VARIABLES PARA STEP FUNCTIONS =========================================

#============================== FIN VARIABLES PARA STEP FUNCTIONS =============================
#======================= VARIABLES PARA AWS GLUE JOB =========================================
name_rol_glue = "glue-job-role"
job_name_glue = "job-ecommerce-logs"

job_tags_glue = {
  Name       = "Glue Job Procesar"
  Owner      = "TORRES IAM"
  Enviroment = "prod"
  Capa       = "Glue"
  Action     = "Procesar"
}
name_policy_glue_job = "policy-job-all-permisos"
bucket_glue = "logs-glue-scripts"
#============================== FIN VARIABLES PARA AWS GLUE JOB =============================
