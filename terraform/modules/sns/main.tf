resource "aws_sns_topic" "pipeline_notifications" {
    name = var.name_sns_topic
    tags = var.tags_sns
}


resource "aws_sns_topic_subscription" "subscription_topic_alert" {
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol = "email"
  endpoint = var.endpoint_email
}