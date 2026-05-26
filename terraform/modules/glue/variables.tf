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
variable "name_crawler" {
  type = string
  description = "nombre de los crawlers para identificar la data"
}
variable "crawler_role_arn" {
  type = string
  description = "el arn del rol de iam"
}
variable "paths_buckets" {
  type = list(string)
  description = "variable para pooner los prefix de los buckets"
}
variable "bucket_id_crawler" {
  type = string
  description = "Id de los Buckets a identificar"
}
variable "tags_crawlers" {
  default = {}
  description = "tags para los crawler"
}
#======================================================================
#=============================== VARIABLES AWS GLUE JOB =========================
#variable "name_job" {
#  type = string
#  description = "Variable para asiganarle valor al nombre del job"
#}
#variable "tags_jobs" {
#  default = {}
#  description = "Poner las tags del job etl"
#}

#================================================================================