#IAM Role and Policy for Lambda Function
resource "aws_iam_role" "lambda_exec" {
  name = "OOSOOM_Lambda_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "OOSOOM_Lambda_Policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # --- DynamoDB Permissions ---
        Action    = ["dynamodb:PutItem", "dynamodb:Scan", "dynamodb:DeleteItem"]
        Effect    = "Allow"
        Resource = aws_dynamodb_table.documents.arn
      },
      {
        # --- SNS Permissions ---
        Action    = [
          "sns:Publish",
          "sns:Subscribe",
          "sns:Unsubscribe",
          "sns:ListSubscriptionsByTopic"
        ]
        Effect    = "Allow"
        Resource = aws_sns_topic.alerts.arn
      },
      {
        # --- CloudWatch Logs ---
        Action    = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect    = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}