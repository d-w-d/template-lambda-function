# Template Lambda Function

This repository is intended to be used as a TEMPLATE for creating AWS infrastructure using terraform/tofu.

## Tofu Version

This template was built and tested with:

```
OpenTofu v1.10.6
on darwin_arm64
+ provider registry.opentofu.org/hashicorp/aws v6.18.0
```

If you upgrade tofu/terraform in the future and try to use the state files from this template, you may run into issues. In that case, re-initialize the project with `tofu init -upgrade` after ensuring your version is compatible.

## Workflow

After `cp .env-template .env` and editing `.env` to your liking, the essential workflow is:

```
./_docker
./_tf plan
./_tf apply
```

## Template Essentials

When creating a new project based on this template, ALL such repos MUST have the following:

- docker/Dockerfile
- docker/build.sh
- .env-template
- tf_main.tf
- tf_variables.tf
- tf_outputs.tf
- src/index.ts
- package.json
- tsconfig.json
- \_docker
- \_tf
- AGENTS.md

All other scripts and files are on a per-project basis.

## Features in This Template Lambda Function

Some commonly usedLambda features were chosen for this template:

- Lambda function written in tsc and packaged in an AWS Docker container
- API Gateway to expose the Lambda function via HTTP
- S3 bucket to store files uploaded via the Lambda function
- CloudFront distribution to front the S3 Bucket

## Rationale / Design Decisions

- We only use terraform/tofu with AWS.
- We use a docker container so that our npm modules are installed/built on the target linux platform.
- We have kept the wrapper scripts very simple; \_docker prints the commands it executes, and \_tf is just a thin wrapper around terraform/tofu commands that sources the .env file first.
- ./\_tf prints a guide of commands that I use often

## Terraform/Tofu Config and State Files

Everything related to state is kept in root dir; placing files elesewhere complicates terminal commands, and makes the user dependent on wrapper scripts. See \_tf for details.

## Node Version

- This repo is set for Node 22. If/when AWS Lambda supports Node 24, you need to update `.env-template` and `Dockerfile`.
