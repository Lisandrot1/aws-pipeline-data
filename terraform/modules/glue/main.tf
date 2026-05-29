
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
  name          = var.name_crawler != "" ? 1 : 0
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
resource "aws_s3_object" "glue_scripts" {
  bucket = var.name_bucket_script
  key = "scripts/slv_glue_job.py"
  source = "${path.root}/../src/glue/slv_glue_job.py"
  etag = filemd5("${path.root}/../src/glue/slv_glue_job.py")
}

resource "aws_glue_job" "job_etl" {
  name = var.name_job
  description = "ETL job para procesar datos de bronze a silver."
  role_arn = var.role_glue_job_arn
  max_retries = 1
  glue_version = "5.0"
  timeout = 20
  number_of_workers = 2
  worker_type = "G.1X"
  execution_class = "STANDARD"

  command {
    name = "glueetl"
    script_location = "s3://${aws_s3_object.glue_scripts.bucket}/${aws_s3_object.glue_scripts.key}"
    python_version = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--continuous-log-logGroup"          = "/aws-glue/jobs/${var.name_job}"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = "true"
    "--enable-auto-scaling"              = "true"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-observability-metrics"     = "true"
    "--enable-glue-datacatalog"          = "true"
    "--conf"                             = "spark.sql.parquet.enableVectorizedReader=true"
  }

  tags = var.tags_jobs
  
}
#==========================================================================================