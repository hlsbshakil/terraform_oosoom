# 1. Create Public Bucket
resource "aws_s3_bucket" "frontend" {
  bucket_prefix = "oosoom-website-"
  force_destroy = true
}

# 2. Configure Website Hosting
resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.frontend.id
  index_document {
    suffix = "index.html"
  }
}

# 3. Allow Public Access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Set Bucket Policy for Public Read
resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.frontend.id
  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

# 5. Generate and Upload config.js (This holds the dynamic API URL). Extremly cool suggestion from Gemini AI instead of hardcoding the html file!
#Useful for terraform destroy/create cycles
resource "aws_s3_object" "config_js" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "config.js"
  content_type = "application/javascript"
  
  # Terraform writes the file content right here:
  content      = "window.CONFIG = { API_BASE: '${aws_apigatewayv2_api.http_api.api_endpoint}' };"
  
  # Trigger update if URL changes
  etag         = md5("window.CONFIG = { API_BASE: '${aws_apigatewayv2_api.http_api.api_endpoint}' };")
}

# --- 6 & 7. CONSOLIDATED UPLOAD OF STATIC ASSETS (HTML, CSS, JPG) ---
resource "aws_s3_object" "site_assets" {
  for_each = fileset("./", "*.{html,css,jpg}") # Finds all these files in the current directory

  bucket       = aws_s3_bucket.frontend.id
  key          = each.value
  source       = each.value
  content_type = lookup({
    # Mapping file extensions to MIME types
    "html" = "text/html",
    "css"  = "text/css",
    "jpg"  = "image/jpeg",
  }, split(".", each.value)[1], "application/octet-stream") # Guesses content type from extension
  etag         = filemd5(each.value)
}

# 8. Output URL. Useful for testing after 'terraform apply'
output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.hosting.website_endpoint}"
}