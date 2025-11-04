# Template Lambda Function

This repository is intended to be used as a TEMPLATE for creating AWS infrastructure using terraform/tofu. This template inlcudes the following since they are the most common things that I tend to want to create using tofu/terraform.

## Overview

- Lambda function written in tsc and packaged in an AWS Docker container
- API Gateway to expose the Lambda function via HTTP
- S3 bucket to store files uploaded via the Lambda function
- CloudFront distribution to front the API Gateway

## Rationale

We only use terraform/tofu with AWS. We use a docker container so that our npm modules are installed/built on the target linux platform.

I have opted for very simple scripts to operate this repo, in order to promote user familiarity with the CLI tools. The \_docker script just prints out and wraps around the docker build and run commands needed, and the \_tf_guide reminds the user how to use terraform/tofu to deploy the infrastructure.

## Terraform/Tofu Config and State Files

Everything related to state is kept in root dir; placing files elesewhere complicates terminal commands, and makes the user dependent on wrapper scripts. See \_tf_guide for details.

## Misc Notes

- TF_VAR_LAMBDA_ARCHITECTURE="x86_64": you will get generally better compatibility with npm modules with x86, but the cold start times are slower and the cost is slightly higher. If you swap to "arm64", you will need to change the Dockerfile to use the arm64 version of the AWS lambda base image!
