#===================== DATA CATALOG VARIABLES ==========================
variable "name_database" {
  type =  string
  description = "nombre de las bases de datos data catalog"
}

variable "tags_data_catalog" {
  default = {}
  description = "variable para las tags de la db metadatos"
}
#===========================================================================
#============================ AWS GLUE CRAWLER VARIABLES ===================
variable "create_crawler" {
  type = bool
  default = false
  description = "si es true, se crea el crawler"
}
variable "name_crawler" {
  type = string
  default = null
  description = "nombre de los crawlers para identificar la data"
}
variable "crawler_role_arn" {
  type = string
  default = null
  description = "el arn del rol de iam"
}
variable "paths_buckets" {
  type = list(string)
  default = null
  description = "variable para pooner los prefix de los buckets"
}
variable "bucket_id_crawler" {
  type = string
  default = null
  description = "Id de los Buckets a identificar"
}
variable "tags_crawlers" {
  default = {}
  description = "tags para los crawler"
}
#======================================================================
#=============================== VARIABLES AWS GLUE JOB =========================
variable "create_job" {
  type = bool
  default = false
  description = "si es true, se crea el job"
  
}
variable "name_job" {
  type = string
  default = null
  description = "Variable para asiganarle valor al nombre del job"
}
variable "tags_jobs" {
  default = {}
  description = "Poner las tags del job etl"
}
variable "role_glue_job_arn" {
  type = string
  default = null
  description = "nombre del role para sacar el arn"
}

variable "name_bucket_script" {
  type = string
  default = null
  description = "bucket para insertar los script de glue"
}

variable "script_name_file" {
  type = string
  default = null
  description = "nombre del file del job de aws glue"
}
variable "script_name_path" {
  type = string
  default = null
  description = "nombre del path del job de aws glue"
}
#================================================================================