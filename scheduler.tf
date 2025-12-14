# 1. Create the Schedule (The Timer)
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "OOSOOM_Daily_Trigger"
  description         = "Triggers the document checker every day"
  schedule_expression = "cron(0 12 * * ? *)" 
}

# 2. Connect the Schedule to the Lambda
resource "aws_cloudwatch_event_target" "target_lambda" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.daily_check.arn
}

# 3. Give Permission to EventBridge to Invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily_check.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}