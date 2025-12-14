resource "aws_sns_topic" "alerts" {
  name = "OOSOOM_Alerts_Topic"
}

# Output the Topic ARN so Lambda can use it
output "topic_arn" {
  value = aws_sns_topic.alerts.arn
}