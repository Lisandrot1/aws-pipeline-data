module "s3_bronze" {
  source = "./modules/s3"
  bucket_name = var.bucket_bronze

  tags = var.tags_bronze

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  lifecycle_config = var.lifecycle_bronze
}
module "s3_silver" {
  source = "./modules/s3"
  bucket_name = var.bucket_silver

  tags = var.tags_silver

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  
  lifecycle_config = var.lifecycle_silver
}

module "s3_gold" {
  source = "./modules/s3"
  bucket_name = var.bucket_gold

  tags = var.tags_gold

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  lifecycle_config = var.lifecycle_gold
}
#================== FIN MODULOS S3 =======================================================

#======================= INICIO MODULOS AWS GLUE ==========================================

module "db_bronze" {
  source = "./modules/glue"
  #nombre de la base de datos
  name_database = var.db_catalog_bronze
  # tags de la db
  tags_data_catalog = var.tags_db_brz
  #arn del role para el crawler
  crawler_role_arn = aws_iam_role.glue-crawler-role.arn
  # id del bucket de bronze
  bucket_id_crawler = module.s3_bronze.bucket-id
  # nombre del crawler
  name_crawler = var.crawler_bronze
  #lista de las tablas del bucket de bronze
  paths_buckets = var.path_bronze
}


#module "db_silver" {
#  source = "./modules/glue"
#  name_database = var.db_catalog_silver
#  tags_data_catalog = var.tags_db_slv

#  name_crawler = var.crawler_silver
#}
#module "db_gold" {
#  source = "./modules/glue"
##  name_database = var.db_catalog_gold
#  tags_data_catalog = var.tags_gold
#
#  name_crawler = var.crawler_gold
#}

#============================= FIN MODULOS AWS GLUE =============================================