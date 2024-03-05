resource "aws_s3_bucket" "lambda_thumbgenerator_bucket" {
  bucket = var.thumbnail_bucket_name

  tags = {
    Name         = "${var.thumbnail_bucket_name} Thumbnail Storage"
    Environment  = var.environment
    Project_name = var.project_name
  }
}

resource "aws_s3_bucket_ownership_controls" "lambda_thumbgenerator_bucket_ownership_controls" {
  bucket = aws_s3_bucket.lambda_thumbgenerator_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_thumbgenerator_bucket_public_access_allow" {
  bucket = aws_s3_bucket.lambda_thumbgenerator_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "lambda_thumbgenerator_bucket_acl" {
  bucket = aws_s3_bucket.lambda_thumbgenerator_bucket.id

  acl = "public-read"

  depends_on = [
    aws_s3_bucket_public_access_block.lambda_thumbgenerator_bucket_public_access_allow,
    aws_s3_bucket_ownership_controls.lambda_thumbgenerator_bucket_ownership_controls
  ]
}

resource "aws_s3_bucket_policy" "lambda_thumbgenerator_bucket_policy" {
  bucket = aws_s3_bucket.lambda_thumbgenerator_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadForGetObjects",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.thumbnail_bucket_name}/static*/"
      }
    ]
  })
}

# Set the lambda function as an event trigger for the S3 bucket
resource "aws_s3_bucket_notification" "lambda_thumbgenerator_bucket_notification" {
  bucket = aws_s3_bucket.lambda_thumbgenerator_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.thumbgenerator_lambda.arn
    events              = ["s3:ObjectPut:*"]
    filter_prefix       = "static/uploads/"
    filter_suffix       = ".jpg"
  }
}
