resource "aws_sfn_state_machine" "step_functions_resource" {
    name = var.name_step_functions
    role_arn = var.role_arn_step_functions
    definition = templatefile("${path.root}/../src/stepfunctions/workflow.json", {})
    type = "STANDARD"
}

#==============================================================

