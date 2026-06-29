variable "name_sns_topic" {
  type = string
  description = "nombre del topic para las notificaciones"
}

variable "endpoint_email" {
  type = string
  description = "nombre del email donde va a llegar la notificacion"
}

variable "tags_sns" {
  default = {}
  description = "value"
}