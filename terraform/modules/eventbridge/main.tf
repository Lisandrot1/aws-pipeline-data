resource "aws_scheduler_schedule" "event_bridge_etl" {
  name = var.name_eventbridge
  description = "eventBridge para el cron de step"
  group_name = ""
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = ""
  target {
    role_arn = var.role_arn
    arn = var.arn_name
  }
}