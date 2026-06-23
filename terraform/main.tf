module "s3_bronze" {
  source                  = "./modules/s3"
  bucket_name             = var.bucket_bronze
  tags                    = var.tags_bronze
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  lifecycle_config        = var.lifecycle_bronze
}
module "s3_silver" {
  source = "./modules/s3"
  bucket_name             = var.bucket_silver
  tags                    = var.tags_silver
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  lifecycle_config        = var.lifecycle_silver
}

module "s3_gold" {
  source                  = "./modules/s3"
  bucket_name             = var.bucket_gold
  tags                    = var.tags_gold
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  lifecycle_config = var.lifecycle_gold
}

module "s3_scripts" {
  source = "./modules/s3"
  bucket_name = var.bucket_glue

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
#================== FIN MODULOS S3 =======================================================

#======================= INICIO MODULOS AWS GLUE ==========================================

module "db_bronze" {
  source            = "./modules/glue"
  #============== DATA CATALOG ============
  name_database     = var.db_catalog_bronze
  tags_data_catalog = var.tags_db_brz
  # ======================================
  #============== AWS GLUE CRAWLER ============
  create_crawler    = true
  # nombre del crawler
  name_crawler      = var.crawler_bronze
  # id del bucket de bronze
  bucket_id_crawler = module.s3_bronze.bucket_id
  #arn del role para el crawler
  crawler_role_arn  = aws_iam_role.glue_crawler_role.arn
  #lista de las tablas del bucket de bronze
  paths_buckets     = var.path_bronze
  #tags
  tags_crawlers     = var.tags
  # ======================================
  #============= AWS GLUE JOB ============
  create_job         = true
  script_name_file   = "slv_glue_job.py"
  script_name_path   = "slv_glue_job.py"
  name_job           = var.job_name_glue
  tags_jobs          = var.job_tags_glue
  role_glue_job_arn  = aws_iam_role.glue_job_role.arn
  name_bucket_script = module.s3_scripts.bucket_id
  # ======================================
}

module "db_silver" {
  source            = "./modules/glue"
  name_database     = var.db_catalog_silver
  tags_data_catalog = var.tags_db_slv
}

module "db_gold" {
  source            = "./modules/glue"
  name_database     = var.db_catalog_gold
  tags_data_catalog = var.tags_gold

  # =================== AWS GLUE JOB =======
  create_job         = true
  script_name_file   = "gld_glue_job.py"
  script_name_path   = "gld_glue_job.py"
  name_job           = var.gld_job_ecommerce
  tags_jobs          = var.gld_tags_glue
  role_glue_job_arn  = aws_iam_role.glue_job_role.arn
  name_bucket_script = module.s3_scripts.bucket_id
}

#============================= FIN MODULOS AWS GLUE =============================================

#========================================= INICIO MODULOS AWS LAMBDA ============================
module "data_lambda" {
  source          = "./modules/lambda"
  role_iam_lambda = aws_iam_role.read_s3_lambda.arn
  name_lambda     = var.lambda_name
  tags_lambda     = var.lambda_tags
}
#======================= FIN MODULO PARA AWS LAMBDA =========================================

#======================= MODULO PARA STEP FUNCTIONS =========================================
module "step_functions_orch" {
  source                  = "./modules/stepfunction"
  name_step_functions     = var.step_functions_name
  role_arn_step_functions = aws_iam_role.orch_step_role.arn
}
#============================== FIN MODULO PARA STEP FUNCTIONS =============================
#============================== INICIO MODULO PARA EVENTBRIGDE =============================
module "event_brigde_orch" {
  source           = "./modules/eventbridge"
  name_eventbridge = var.event_drigde_name
  arn_name_step    = module.step_functions_orch.step_arn
  role_arn_step    = aws_iam_role.eventbrigde_role.arn
}
#============================== FIN MODULO PARA EVENTBRIGDE =============================