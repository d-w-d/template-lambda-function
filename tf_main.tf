provider "aws" {
  region = var.AWS_REGION

  # Prevent Terraform from loading shared config files so that env vars are the single source of truth.
  shared_config_files      = ["${path.module}/.no_aws_config"]
  shared_credentials_files = ["${path.module}/.no_aws_credentials"]
}

locals {
  bucket_name          = "${var.PROJECT_PREFIX}${var.S3_BUCKET_NAME}"
  lambda_function_name = "${var.PROJECT_PREFIX}${var.LAMBDA_FUNCTION_NAME}"
  iam_role_name        = "${var.PROJECT_PREFIX}${var.LAMBDA_FUNCTION_NAME}-role"
  iam_policy_name      = "${var.PROJECT_PREFIX}iam-policy"
  api_gateway_name     = "${var.PROJECT_PREFIX}api"
  lambda_runtime       = var.LAMBDA_RUNTIME
  api_gateway_access_log_group_name = "/aws/apigateway/${var.PROJECT_PREFIX}${var.LAMBDA_DEPLOYMENT}/access"
  api_gateway_logging_role_name     = "${var.PROJECT_PREFIX}apigw-logs-role"
}

# S3 Bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_public_access_block" "lambda_bucket_public_access" {
  bucket = aws_s3_bucket.lambda_bucket.id

  block_public_acls       = !var.S3_PUBLIC_READ
  block_public_policy     = !var.S3_PUBLIC_READ
  ignore_public_acls      = !var.S3_PUBLIC_READ
  restrict_public_buckets = !var.S3_PUBLIC_READ
}

data "aws_iam_policy_document" "lambda_bucket" {
  statement {
    sid    = "AllowCloudFrontAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.lambda_bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }

  dynamic "statement" {
    for_each = var.S3_PUBLIC_READ ? [1] : []

    content {
      sid    = "PublicReadGetObject"
      effect = "Allow"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions   = ["s3:GetObject"]
      resources = ["${aws_s3_bucket.lambda_bucket.arn}/*"]
    }
  }
}

resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.lambda_bucket.id
  policy = data.aws_iam_policy_document.lambda_bucket.json

  depends_on = [aws_s3_bucket_public_access_block.lambda_bucket_public_access]
}

# Lambda Function
resource "aws_lambda_function" "s3_writer_lambda" {
  filename         = "lambda.zip"
  function_name    = local.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  description      = var.LAMBDA_FUNCTION_DESC
  runtime          = local.lambda_runtime
  timeout          = var.LAMBDA_MAX_RUNTIME_SECONDS
  architectures    = [var.LAMBDA_ARCHITECTURE]
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      S3_BUCKET_NAME    = local.bucket_name
      S3_FILE_PREFIX    = var.S3_FILE_PREFIX
      CLOUDFRONT_DOMAIN = aws_cloudfront_distribution.s3_distribution.domain_name
      DEPLOYMENT        = var.LAMBDA_DEPLOYMENT
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  count             = var.LAMBDA_LOGS_TO_CLOUDWATCH ? 1 : 0
  name              = "/aws/lambda/${aws_lambda_function.s3_writer_lambda.function_name}"
  retention_in_days = var.LAMBDA_LOGS_RETENTION_DAYS
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = local.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda to access S3
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = local.iam_policy_name
  description = "IAM policy for Lambda to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutObjectAcl"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.lambda_bucket.arn}/*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = local.api_gateway_logging_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  name = "${local.api_gateway_logging_role_name}-policy"
  role = aws_iam_role.api_gateway_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}

# API Gateway
resource "aws_api_gateway_rest_api" "lambda_api" {
  name        = local.api_gateway_name
  description = "API Gateway for S3 Writer Lambda"
}

resource "aws_api_gateway_resource" "lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "write"
}

resource "aws_api_gateway_method" "lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_resource.lambda_resource.id
  http_method             = aws_api_gateway_method.lambda_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.s3_writer_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_writer_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/${aws_api_gateway_stage.lambda_stage.stage_name}/${aws_api_gateway_method.lambda_method.http_method}${aws_api_gateway_resource.lambda_resource.path}"

  depends_on = [
    aws_api_gateway_stage.lambda_stage
  ]
}

resource "aws_api_gateway_deployment" "lambda_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  triggers = {
    redeploy = aws_lambda_function.s3_writer_lambda.source_code_hash
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = local.api_gateway_access_log_group_name
  retention_in_days = var.LAMBDA_LOGS_RETENTION_DAYS
}

resource "aws_api_gateway_stage" "lambda_stage" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  stage_name    = var.LAMBDA_DEPLOYMENT
  deployment_id = aws_api_gateway_deployment.lambda_deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format = jsonencode({
      requestId                 = "$context.requestId"
      ip                        = "$context.identity.sourceIp"
      caller                    = "$context.identity.caller"
      user                      = "$context.identity.user"
      requestTime               = "$context.requestTime"
      httpMethod                = "$context.httpMethod"
      resourcePath              = "$context.resourcePath"
      status                    = "$context.status"
      protocol                  = "$context.protocol"
      responseLength            = "$context.responseLength"
      integrationStatus         = "$context.integration.status"
      integrationErrorMessage   = "$context.integration.error"
      integrationLatency        = "$context.integration.latency"
      integrationRequestId      = "$context.integration.requestId"
      integrationServiceStatus  = "$context.integration.status"
      integrationServiceLatency = "$context.integration.latency"
    })
  }

  description = "Stage for ${local.lambda_function_name}"

  depends_on = [
    aws_api_gateway_account.main,
    aws_cloudwatch_log_group.api_gateway_access_logs
  ]
}

resource "aws_api_gateway_method_settings" "logging" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  stage_name  = aws_api_gateway_stage.lambda_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
    data_trace_enabled = true
  }

  depends_on = [
    aws_api_gateway_account.main
  ]
}

# CloudFront origin access control to keep the S3 bucket private.
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.PROJECT_PREFIX}s3-oac"
  description                       = "Origin access control for ${local.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.lambda_bucket.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = var.CLOUDFRONT_PRICE_CLASS
  comment             = var.CLOUDFRONT_DESCRIPTION

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 39600
    max_ttl                = 39600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
