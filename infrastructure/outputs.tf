output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = "${aws_api_gateway_deployment.lambda_deployment.invoke_url}${aws_api_gateway_resource.lambda_resource.path}"
}

output "cloudfront_domain" {
  description = "CloudFront domain name"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.lambda_bucket.bucket
}