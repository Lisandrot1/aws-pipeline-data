output "topic_arn" {
  value = aws_sns_topic.pipeline_notifications.arn
}

output "subscription_arn" {
  value = aws_sns_topic_subscription.subscription_topic_alert.arn
}