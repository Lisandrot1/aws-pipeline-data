# ================================ ROLE AWS GLUE CRAWLER ===============================================

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
#===============================================================================
#===================== ROL LAMBDA LECTURA S3 ===================================

resource "aws_iam_role" "read_s3_lambda" {
  name = var.name_rol_lambda
  assume_role_policy = jsonencode({
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_lambda" {
  role = aws_iam_role.read_s3_lambda.name
  policy_arn = aws_iam_policy.ReadS3Lambda.arn
}
#==========================================================================================================