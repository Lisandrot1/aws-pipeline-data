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