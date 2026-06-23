variable "name_eventbridge" {
  type = string
  description = "nombre del cron para el step functions"
}

variable "role_arn" {
  type = string
  description = "arn del rol para que event se ejecute"
}

variable "arn_name" {
  type = string
  description = "arn"
}