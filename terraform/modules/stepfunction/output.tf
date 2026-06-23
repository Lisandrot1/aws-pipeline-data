output "step_arn" {
  value = aws_sfn_state_machine.step_functions_resource.arn
}
output "step_id" {
  value = aws_sfn_state_machine.step_functions_resource.id
}