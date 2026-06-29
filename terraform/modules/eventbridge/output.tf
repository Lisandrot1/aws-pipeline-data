output "event_arn" {
  value = aws_scheduler_schedule.event_bridge_etl.arn
}

output "event_id" {
  value = aws_scheduler_schedule.event_bridge_etl.id
}