resource "aws_scheduler_schedule" "event_bridge_etl" {
  name = var.name_eventbridge
  description = "eventBridge para el cron de step"
  group_name = "default"

  schedule_expression = "cron(0 1 * * ? *)"
  schedule_expression_timezone = "America/Bogota"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    role_arn = var.role_arn_step
    arn = var.arn_name_step
  }

}