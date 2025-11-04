variable "DID_YOU_SOURCE_ENV" {
  description = "This is a reminder to ALWAYS source .env before using tofu/terrform"
  type        = string
}

variable "AWS_REGION" {
  description = "AWS region"
  type        = string
}

variable "PROJECT_PREFIX" {
  description = "Unique, descriptive prefix applied to named resources. Must end with a hyphen if you plan to append suffixes."
  type        = string
  default     = "sbn-lambda-s3-template-"
}

variable "LAMBDA_FUNCTION_NAME" {
  description = "Name of the Lambda function"
  type        = string
}

variable "LAMBDA_FUNCTION_DESC" {
  description = "Description for the Lambda function"
  type        = string
  default     = ""
}

variable "LAMBDA_RUNTIME" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "nodejs22.x"
}

variable "LAMBDA_ARCHITECTURE" {
  description = "Architecture for the Lambda function"
  type        = string
  default     = "arm64"
}

variable "LAMBDA_MAX_RUNTIME_SECONDS" {
  description = "Maximum runtime (timeout) for the Lambda function"
  type        = number
  default     = 30
}

variable "LAMBDA_DEPLOYMENT" {
  description = "Deployment label for the Lambda function"
  type        = string
  default     = "prod"
}

variable "LAMBDA_LOGS_TO_CLOUDWATCH" {
  description = "Whether to create a CloudWatch Log Group for the Lambda"
  type        = bool
  default     = true
}

variable "LAMBDA_LOGS_RETENTION_DAYS" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 14
}

variable "S3_BUCKET_NAME" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "S3_FILE_PREFIX" {
  description = "Prefix for files created in the S3 bucket"
  type        = string
  default     = "hello-world"
}

variable "API_GATEWAY_STAGE" {
  description = "Stage name for API Gateway"
  type        = string
  default     = "prod"
}

variable "CLOUDFRONT_PRICE_CLASS" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "CLOUDFRONT_DESCRIPTION" {
  description = "Description for the CloudFront distribution"
  type        = string
  default     = "S3 Writer Lambda"
}
