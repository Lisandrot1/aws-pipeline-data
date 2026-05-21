resource "aws_sfn_state_machine" "step_functions_resource" {
    name = var.name_step_functions
    role_arn = ""
    definition = ""
    type = "STANDARD"
}

#==============================================================

