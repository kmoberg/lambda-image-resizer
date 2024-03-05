variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "thumbnail_bucket_name" {
  description = "The name of the thumbnail bucket"
  type        = string
}

variable "lambda_resizer_name" {
  description = "The name of the lambda resizer"
  type        = string
}

variable "lambda_resizer_layer_name" {
  description = "The name of the lambda resizer layer"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "environment" {
  description = "The environment to deploy to"
  type        = string
}
