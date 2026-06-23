output "lambda_arn" {
  value = aws_lambda_function.identity_lambda.arn
}

output "lambda_id" {
  value = aws_lambda_function.identity_lambda.id
}