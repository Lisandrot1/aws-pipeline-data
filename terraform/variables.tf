variable "region" {
  type = string
  description = "Region donde estaremos trabajando"
}
#================== BUCKET BRONZE ==================
variable "bucket_bronze" {
  type = string
  description = "Nombre del bucket de bronze"
}

variable "tags_bronze" {
  default = {}
  description = "tags para el bucket de bronze"
}

variable "lifecycle_bronze" {
  description = "Lifecycle configuration for bronze bucket"
  type = object({
    enable_lifecycle_rule                    = bool
    transition_days_standard_ia              = number
    transition_days_glacier                  = number
    noncurrent_version_transition_days       = number
    noncurrent_version_expiration_days       = number
    enable_expired_object_delete_marker      = bool
    enable_abort_incomplete_multipart_upload = bool
    abort_incomplete_multipart_upload_days   = number
    enable_direct_glacier                    = bool
    transition_days_glacier_direct           = number
  })
  default = null
}
#===================================================
#================== BUCKET SILVER ==================

variable "bucket_silver" {
  type = string
  description = "Nombre del bucket de silver"
}

variable "tags_silver" {
  default = {}
  description = "Tags para el bucket de silver"
}

variable "lifecycle_silver" {
  description = "Lifecycle configuration for silver bucket"
  type = object({
    enable_lifecycle_rule                    = bool
    transition_days_standard_ia              = number
    transition_days_glacier                  = number
    noncurrent_version_transition_days       = number
    noncurrent_version_expiration_days       = number
    enable_expired_object_delete_marker      = bool
    enable_abort_incomplete_multipart_upload = bool
    abort_incomplete_multipart_upload_days   = number
    enable_direct_glacier                    = bool
    transition_days_glacier_direct           = number
  })
  default = null
}
#=================================================
#================== BUCKET GOLD ==================

variable "bucket_gold" {
  type = string
  description = "Nombre del bucket para gold"
}

variable "tags_gold" {
  default = {}
  description = "Tags para el bucket de gold"
}

variable "lifecycle_gold" {
  description = "Lifecycle configuration for gold bucket"
  type = object({
    enable_lifecycle_rule                    = bool
    transition_days_standard_ia              = number
    transition_days_glacier                  = number
    noncurrent_version_transition_days       = number
    noncurrent_version_expiration_days       = number
    enable_expired_object_delete_marker      = bool
    enable_abort_incomplete_multipart_upload = bool
    abort_incomplete_multipart_upload_days   = number
    enable_direct_glacier                    = bool
    transition_days_glacier_direct           = number
  })
  default = null
}

#======================================================

#==============  VARIABLES DE BLOQUEO DE BUCKET PRIVADO ======================
variable "block_public_acls" {
  type = bool
}
variable "block_public_policy" {
  type = bool
}
variable "ignore_public_acls" {
  type = bool
}
variable "restrict_public_buckets" {
  type = bool
}

#=========================================================================

#===========================VARIABLES IAM =================================

variable "name_role_crawler" {
  type = string
  description = "Variable para poner nombres de los crawlers"
}
#==========================================================================

#============== VARIABLES GENERALES DE AWS GLUE ============================
# NOMBRES BASES DE DATOS DATA CATALOG
variable "db_catalog_bronze" {
  type = string
  description = "Nombre de la db de metadatos de bronze"
}
variable "db_catalog_silver" {
  type = string
  description = "Nombre de la db de metadatos de silver"
}
variable "db_catalog_gold" {
  type = string
  description = "Nombre de la db de metadatos de gold"
}

# VARIABLES TAGS
variable "tags_db_brz" {
  default = {}
  description = "Tags para la db de metadatos de bronze"
}
variable "tags_db_slv" {
  default = {}
  description = "Tags para la db de metadatos de silver"
}
variable "tags_db_gld" {
  default = {}
  description = "Tags para la db de metadatos de gold"
}
#=========================
variable "crawler_bronze" {
  type = string
  description = "Nombre del crawler de bronze"
}
variable "crawler_silver" {
  type = string
  description = "Nombre del crawler de silver"
}
variable "crawler_gold" {
  type = string
  description = "Nombre del crawler de gold"
}
#======
variable "path_bronze" {
  type = list(string)
  description = "Lista de las tablas de bronze para identificar en el crawler"
}

variable "tags" {
  default = {}
  description = "tags para los crawlers"
}
#===========================================================================

#============================= VARIABLES PARA LA LAMBDA AWS ==================

variable "name_policy_lambda" {
  type = string
  description = "Nombre variable poliicy lambda"
}
variable "name_rol_lambda" {
  type = string
  description = "Nombre variable Rol de  lambda"
}
variable "lambda_name" {
  type = string
  description = "variable Nombre lambda"
}
variable "lambda_tags" {
  default = {}
  description = "Tags para la lambda."
}
#============================== FIN VARIABLES PARA AWS LAMBDA

#======================= VARIABLES PARA STEP FUNCTIONS =========================================

#============================== FIN VARIABLES PARA STEP FUNCTIONS =============================


#============================ AWS GLUE JOB ============================================================
variable "name_rol_glue" {
  type = string
  description = "nombre rol para aws glue job"
}
variable "job_name" {
  type = string
  description = "nombre del job de glue"
}
variable "job_tags" {
  default = {}
  description = "tags para el job"
}
variable "name_policy_glue_job" {
  type = string
  description = "nombre del policy para glue job"
}
#==========================================================================================================