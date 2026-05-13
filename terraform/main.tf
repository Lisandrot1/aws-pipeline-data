module "s3_silver" {
  source = "./modules/s3"
  bucket_name = var.bucket_silver
}

module "s3_gold" {
  source = "./modules/s3"
  bucket_name = var.bucket_gold
}
