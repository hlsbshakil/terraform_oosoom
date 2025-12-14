# --- Function 1: Add Document ---
# 1. Zip the Python code for Lambda. Lambda requires a .zip file upload.
data "archive_file" "zip_add" {
  type        = "zip"
  source_file = "add_document.py"
  output_path = "add_document.zip"
}

# 2. Define the Lambda Function
resource "aws_lambda_function" "add_doc" {
  filename         = data.archive_file.zip_add.output_path
  function_name    = "OOSOOM_AddDocument"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "add_document.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.zip_add.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.documents.name # DynamoDB Table Name
    }
  }
}

# --- Function 2: Daily Check (The Scheduler) ---

# 1. Zip the Python code
data "archive_file" "zip_check" {
  type        = "zip"
  source_file = "daily_check.py"
  output_path = "daily_check.zip"
}

# 2. Define the Function
resource "aws_lambda_function" "daily_check" {
  filename         = data.archive_file.zip_check.output_path
  function_name    = "OOSOOM_DailyCheck"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "daily_check.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.zip_check.output_base64sha256
  timeout     = 10   

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.documents.name
      TOPIC_ARN  = aws_sns_topic.alerts.arn
    }
  }
}



# --- Function 3: Get Documents ---

data "archive_file" "zip_get" {
  type        = "zip"
  source_file = "get_documents.py"
  output_path = "get_documents.zip"
}

resource "aws_lambda_function" "get_docs" {
  filename         = data.archive_file.zip_get.output_path
  function_name    = "OOSOOM_GetDocuments"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "get_documents.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.zip_get.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.documents.name
    }
  }
}

# --- Function 4: Delete Document ---
data "archive_file" "zip_delete" {
  type        = "zip"
  source_file = "delete_document.py"
  output_path = "delete_document.zip"
}

resource "aws_lambda_function" "delete_doc" {
  filename         = data.archive_file.zip_delete.output_path
  function_name    = "OOSOOM_DeleteDocument"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "delete_document.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.zip_delete.output_base64sha256

  environment {
    variables = { TABLE_NAME = aws_dynamodb_table.documents.name }
  }
}

# --- Function 5: Manage Emails (Subscribe/Unsubscribe) ---
data "archive_file" "zip_email" {
  type        = "zip"
  source_file = "manage_email.py"
  output_path = "manage_email.zip"
}

resource "aws_lambda_function" "manage_email" {
  filename         = data.archive_file.zip_email.output_path
  function_name    = "OOSOOM_ManageEmail"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "manage_email.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.zip_email.output_base64sha256

  environment {
    variables = { TOPIC_ARN = aws_sns_topic.alerts.arn }
  }
}