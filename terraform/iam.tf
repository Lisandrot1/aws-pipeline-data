# IAM PARA GLUE CRAWLER PARA LEER S3 =====================
resource "aws_iam_policy" "crawler-to-s3" {
  name = "permisos-crawler-s3"
  policy = data.aws_iam_policy_document.crawler-to-s3.json

  
}

data "aws_iam_policy_document" "crawler-to-s3" {
    statement {
      sid = "ReadOnPermisoS3"
      effect = "Allow"
      actions = [ 
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetBucketLocation"
       ]
       resources = [
        "${module.s3_bronze.bucket-arn}",
        "${module.s3_bronze.bucket-arn}/*",
        "${module.s3_silver.bucket-arn}",
        "${module.s3_silver.bucket-arn}/*"
       ]
    }
}
#=============================================================