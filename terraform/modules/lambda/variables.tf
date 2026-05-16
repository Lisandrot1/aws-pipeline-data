variable "name_lambda" {
  type = string
  description = "Nombre variable de lambda"
}

variable "tags_lambda" {
  default = {}
  description = "Tags para las fucniones lambda"
}

variable "role_iam_lambda" {
  type = string
  description = "Variable para traer el arn del rol"
}