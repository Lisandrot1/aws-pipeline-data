output "catalgoo_db_arn" {
  value = aws_glue_catalog_database.databases_metadatos.arn
}

output "catalgoo_db_id" {
  value = aws_glue_catalog_database.databases_metadatos.id
}

output "jobs_etl_arn" {
  value = aws_glue_job.job_etl[*].arn
}
