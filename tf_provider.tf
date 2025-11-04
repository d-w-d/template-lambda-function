provider "aws" {
  region = var.AWS_REGION
# Disable loading of shared config and credentials files
# This forces tf to use ENV VARS for AWS authentication
  shared_config_files      = ["${path.module}/.no_aws_config"]
  shared_credentials_files = ["${path.module}/.no_aws_credentials"]
}
