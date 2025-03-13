variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_file_prefix" {
  description = "Prefix for files in S3"
  type        = string
  default     = "hello-world"
}

variable "api_gateway_stage" {
  description = "Stage name for API Gateway"
  type        = string
  default     = "prod"
}

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "cloudfront_description" {
  description = "Description for the CloudFront distribution"
  type        = string
  default     = "S3-WRITER-LAMBDA"
}