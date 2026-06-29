variable "name_eventbridge" {
  type = string
  description = "nombre del cron para el step functions"
}

variable "role_arn_step" {
  type = string
  description = "arn del rol para que event se ejecute"
}

variable "arn_name_step" {
  type = string
  description = "arn"
}