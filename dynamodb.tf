resource "aws_dynamodb_table" "documents" {
  name           = "OOSOOM_Documents"
  billing_mode   = "PAY_PER_REQUEST"
  
  # CHANGE: Name is now the Key
  hash_key       = "documentName"

  attribute {
    name = "documentName"
    type = "S"
  }
}