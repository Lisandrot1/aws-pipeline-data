
#=============== RECURSO AWS GLUE DATA CATALOG ==========================================
resource "aws_glue_catalog_database" "databases_metadatos" {
  name = var.name_database
  description = "Bases de Datos de Metadatos para los buckets (bronze,silver y gold)"
  tags = var.tags_data_catalog
}

#=========================================================================================
#======================= RECURSO AWS GLUE CRAWLER ========================================

resource "aws_glue_crawler" "identity_crawlers" {
  database_name = aws_glue_catalog_database.databases_metadatos.name
  description   = "Crawler para Identificar la data de los buckets"
  name          = var.name_crawler
  role          = var.crawler_role_arn

  tags = var.tags_crawlers
  
  dynamic "s3_target" {
    for_each = var.paths_buckets
    content {
      path = "s3://${var.bucket_id_crawler}/${s3_target.value}"
    }
  }
}
#=============================   RECURSO AWS GLUE JOBS ETL ================================
resource "aws_glue_job" "job_etl" {
  name = ""
  description = "ETL job"
  command {
    name = ""
    script_location = ""
    python_version = ""
  }
  role_arn = ""
  tags = {}
  
}
#==========================================================================================