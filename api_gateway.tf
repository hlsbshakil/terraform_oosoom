# 1. The API Gateway itself (Using HTTP API as its cheaper vs REST API)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "OOSOOM_API"
  protocol_type = "HTTP"

# Enable CORS for front-end access
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "GET", "DELETE", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

# 2. The Stage (Auto-deploy) https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

#--- SECTION 1: ADD DOCUMENT (POST) ---

# Connect API to Lambda (Add Document) https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.add_doc.invoke_arn #Lambda Function definded in lambda.tf
}

# Define the Route (POST /document) https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route
resource "aws_apigatewayv2_route" "post_doc" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /document"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Permission for API to run "Add Document" Lambda https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_doc.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}


# --- SECTION 2: VIEW LIST (GET) ---

# Connect API to Lambda (Get Documents)
resource "aws_apigatewayv2_integration" "get_lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.get_docs.invoke_arn
}

# Define the Route (GET /documents)
resource "aws_apigatewayv2_route" "get_docs_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /documents"
  target    = "integrations/${aws_apigatewayv2_integration.get_lambda_integration.id}"
}

# Permission for API to run "Get Documents" Lambda
resource "aws_lambda_permission" "api_gw_get" {
  statement_id  = "AllowExecutionFromAPIGatewayGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_docs.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}




# --- SECTION 3: DELETE DOCUMENT (DELETE) ---
# 1. Connect API to the Delete Document Lambda
resource "aws_apigatewayv2_integration" "delete_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.delete_doc.invoke_arn
}
# 2. Define the URL (DELETE /document)
resource "aws_apigatewayv2_route" "delete_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "DELETE /document"
  target    = "integrations/${aws_apigatewayv2_integration.delete_integration.id}"
}
# 3. Give Permission
resource "aws_lambda_permission" "api_gw_delete" {
  statement_id  = "AllowExecutionFromAPIGatewayDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_doc.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}


#--- SECTION 4: DAILY CHECK (POST /test-alerts) ---

# 1. Connect API to the Daily Check Lambda
resource "aws_apigatewayv2_integration" "check_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.daily_check.invoke_arn
}

# 2. Define the URL (POST /test-alerts)
resource "aws_apigatewayv2_route" "check_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /test-alerts"
  target    = "integrations/${aws_apigatewayv2_integration.check_integration.id}"
}

# 3. Give Permission
resource "aws_lambda_permission" "api_gw_check" {
  statement_id  = "AllowExecutionFromAPIGatewayCheck"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily_check.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}


#--- SECTION 5: MANAGE EMAIL SUBSCRIPTIONS (POST /email) ---
# 1. Connect API to the Manage Email Lambda
resource "aws_apigatewayv2_integration" "email_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.manage_email.invoke_arn
}

# 2. Define the URL (POST /email)
resource "aws_apigatewayv2_route" "email_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /email"
  target    = "integrations/${aws_apigatewayv2_integration.email_integration.id}"
}

# 3. Give Permission
resource "aws_lambda_permission" "api_gw_email" {
  statement_id  = "AllowExecutionFromAPIGatewayEmail"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.manage_email.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}


# --- OUTPUT THE API URL FOR FRONT-END USE ---
output "api_url" {
  value = "${aws_apigatewayv2_api.http_api.api_endpoint}"
}