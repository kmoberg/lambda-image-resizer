data "archive_file" "thumbgenerator_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../image_resizer"
  output_path = "${path.module}/.terraform/thumbgenerator.zip"
}

# Create the ZIP file with the requirements for the Lambda function
data "archive_file" "requirements_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../requirements/"
  output_path = "${path.module}/.terraform/requirements.zip"
}

# Create the Lambda Layer
resource "aws_lambda_layer_version" "thumbgenerator_requirements_layer" {
  layer_name       = var.lambda_resizer_layer_name
  filename         = data.archive_file.requirements_zip.output_path
  source_code_hash = data.archive_file.requirements_zip.output_base64sha256

  compatible_runtimes = ["python3.11", "python3.12"]
}

# Create the Lambda function
resource "aws_lambda_function" "thumbgenerator_lambda" {
  function_name    = var.lambda_resizer_name
  filename         = data.archive_file.thumbgenerator_zip.output_path
  source_code_hash = data.archive_file.thumbgenerator_zip.output_base64sha256
  timeout          = 120
  memory_size      = 128
  layers = [
    aws_lambda_layer_version.thumbgenerator_requirements_layer.arn,
    "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p312-Pillow:1"
  ]
  runtime = "python3.12"
  handler = "main.lambda_handler"

  role = aws_iam_role.thumbgenerator_lambda_role.arn

  environment {
    variables = {
      S3_BUCKET = var.thumbnail_bucket_name
    }
  }

  depends_on = [aws_lambda_layer_version.thumbgenerator_requirements_layer]

  tags = {
    Name        = var.lambda_resizer_name
    Project     = var.project_name
    Environment = var.environment
  }
}