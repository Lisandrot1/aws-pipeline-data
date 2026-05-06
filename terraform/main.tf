#Bucket CAPA BRONZE
resource "aws_s3_bucket" "capa-bronze" {
  bucket = "bronze-ecommerce-dl"
  tags = {
    Name = "capa_bronze"
    Project = "pipeline-aws"
    Owner = "Torres-IAM"
  }
}
 # VERSIONING

resource "aws_s3_bucket_versioning" "versioning-bronze" {
  bucket = aws_s3_bucket.capa-bronze.id
  versioning_configuration {
    status = "Enabled"
  }
}

# LIFECYCLE
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_bronze" {
  bucket = aws_s3_bucket.capa-bronze.id
  
}