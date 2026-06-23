#======================================== POLICY  AWS GLUE CRAWLER =====================
data "aws_iam_policy_document" "crawler_to_s3" {
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
        "${module.s3_bronze.bucket_arn}",
        "${module.s3_bronze.bucket_arn}/*",
        "${module.s3_silver.bucket_arn}",
        "${module.s3_silver.bucket_arn}/*",
        "${module.s3_gold.bucket_arn}",
        "${module.s3_gold.bucket_arn}/*",
       ]
    }
    statement {
      sid    = "AllowGlueCrawlerLogging"
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = ["*"]
    }
    statement {
      sid = "AllowPermisonGlue"
      effect = "Allow"
      actions = [ 
        "glue:*"
       ]
      resources = [ "*" ]
    }
}

resource "aws_iam_policy" "crawler_to_s3" {
  name = "permisos-crawler-s3"
  policy = data.aws_iam_policy_document.crawler_to_s3.json
}

#==========================================================================================================
#==================================== POLICY AWS LAMBDA ===================================================


data "aws_iam_policy_document" "lambda_to_s3" {
  statement {
    sid = "LeerDataS3"
    effect = "Allow"
    actions = [ 
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetBucketLocation"
     ]
    resources = [ 
        "${module.s3_bronze.bucket_arn}",
        "${module.s3_bronze.bucket_arn}/*"
     ]
  }
  statement {
    sid = "EscribirCatalogo"
    effect = "Allow"
    actions = [ 
      "glue:GetDatabase",
      "glue:CreateTable",
      "glue:GetTable",
      "glue:UpdateTable",
      "glue:CreatePartition"
     ]
     resources = [ 
      "${module.db_bronze.catalgoo_db_arn}" ,
      "${module.db_bronze.catalgoo_db_arn}/*" 
      ]
  }
}

resource "aws_iam_policy" "ReadS3Lambda" {
  name = var.name_policy_lambda
  policy = data.aws_iam_policy_document.lambda_to_s3.json
}




#==========================================================================================================


#============================ AWS GLUE JOB ============================================================

data "aws_iam_policy_document" "job_etl_policy" {
  statement {
    sid = "jobetlecommerce"
    effect = "Allow"
    actions = [
      "s3:PutObject",
			"s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetObject"
    ]
    resources = [
      "${module.s3_bronze.bucket_arn}",
      "${module.s3_bronze.bucket_arn}/*",
      "${module.s3_silver.bucket_arn}",
      "${module.s3_silver.bucket_arn}/*",
      "${module.s3_gold.bucket_arn}",
      "${module.s3_gold.bucket_arn}/*",
      "${module.s3_scripts.bucket_arn}",
      "${module.s3_scripts.bucket_arn}/*"
    ]
  }

  statement {
    sid = "AllglueCatalog"
    effect = "Allow"
    actions = [
      "glue:*"
    ]
    resources = [ "*" ]
  }

  statement {
    sid = "glueLogsCloudwatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [ "*" ]
  }
  statement {
    sid = "passrole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [ "arn:aws:iam::232791540625:role/glue-job-role" ]
  }
}

resource "aws_iam_policy" "policy_glue_all_permisos" {
  name = var.name_policy_glue_job
  policy = data.aws_iam_policy_document.job_etl_policy.json
}

#==========================================================================================================
#=============================== STEP FUNCTIONS ORCHESTRATOR ==============================================
data "aws_iam_policy_document" "orch_step_etl" {
  statement {
    sid = "invokeLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [ "${module.data_lambda.lambda_arn}" ]
  }
  statement {
    sid = "invokeGlue"
    effect = "Allow"
    actions = ["glue:StartJobRun"]
    resources = flatten([module.db_bronze.jobs_etl_arn,
    module.db_gold.jobs_etl_arn])
  }
}
resource "aws_iam_policy" "policy_step_functions_orch" {
  name = var.name_policy_step_functions
  policy = data.aws_iam_policy_document.orch_step_etl.json
}
#==========================================================================================================