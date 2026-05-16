resource "aws_glue_catalog_database" "database_bronze" {
  name = var.name_database
  description = "Bases de Datos de Metadatos para los buckets (bronze,silver y gold)"
  tags = var.tags_data_catalog
  
}