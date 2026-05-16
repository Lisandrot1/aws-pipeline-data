# IAM PARA GLUE CRAWLER PARA LEER S3 =====================
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

resource "aws_iam_policy" "crawler-to-s3" {
  name = "permisos-crawler-s3"
  policy = data.aws_iam_policy_document.crawler-to-s3.json

  
}

resource "aws_iam_role" "glue-crawler-role" {
  name = var.name_role_crawler
  assume_role_policy = jsonencode({
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach-s3-to-crawler" {
  role       = aws_iam_role.glue-crawler-role.name
  policy_arn = aws_iam_policy.crawler-to-s3.arn

}
#=============================================================