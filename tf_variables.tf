
variable "AWS_REGION" {
  description = "AWS region"
  type        = string
}

variable "PROJECT_PREFIX" {
  description = "Unique, descriptive prefix applied to named resources. Must end with a hyphen if you plan to append suffixes."
  type        = string
  default     = "sbn-lambda-s3-template-"
}

variable "LAMBDA_RUNTIME" {
  description = "Lambda runtime identifier (e.g., nodejs22.x or provided.al2023)."
  type        = string
  default     = "nodejs22.x"
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

variable "S3_PUBLIC_READ" {
  description = "Set to true to allow public read access to the bucket (creates permissive policy)."
  type        = bool
  default     = false
}

variable "LAMBDA_DEPLOYMENT" {
  description = "Deployment label for the Lambda function and API Gateway stage"
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
