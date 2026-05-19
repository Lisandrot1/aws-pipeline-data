# Package the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.root}/../src/lambda/identity_data.py"
  output_path = "${path.root}/../src/lambda/identity_data.zip"
}

resource "aws_lambda_function" "identity_lambda" {

    filename = data.archive_file.lambda_zip.output_path
    description = "Lambda para identificar datos Nuevos en los bucket"
    role = var.role_iam_lambda
    function_name = "check-new-data-s3"
    handler = "identity_data.lambda_handler"

    runtime = "python3.12"
    code_sha256 = data.archive_file.lambda_zip.output_base64sha256
    memory_size = 512
    timeout = 30

    

    tags = var.tags_lambda
}
