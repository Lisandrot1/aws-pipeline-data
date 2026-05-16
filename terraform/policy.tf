#======================================== POLICY  AWS GLUE CRAWLER =====================
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
        "${module.s3_silver.bucket-arn}/*",
        "${module.s3_gold.bucket-arn}",
        "${module.s3_gold.bucket-arn}/*",
       ]
    }
}

resource "aws_iam_policy" "crawler-to-s3" {
  name = "permisos-crawler-s3"
  policy = data.aws_iam_policy_document.crawler-to-s3.json
}

#==========================================================================================================
#==================================== POLICY AWS LAMBDA ===================================================


data "aws_iam_policy_document" "lambda-to-s3" {
  statement {
    sid = "LeerDataS3"
    effect = "Allow"
    actions = [ 
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetBucketLocation"
     ]
    resources = [ 
        "${module.s3_bronze.bucket-arn}",
        "${module.s3_bronze.bucket-arn}/*"
     ]
  }
}

resource "aws_iam_policy" "ReadS3Lambda" {
  name = var.name_policy_lambda
  policy = data.aws_iam_policy_document.lambda-to-s3.json
}
#==========================================================================================================