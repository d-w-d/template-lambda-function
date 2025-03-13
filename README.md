# AWS Lambda S3 Writer

This project contains an AWS Lambda function that:

1. Is triggered by a GET request to an API Gateway endpoint
2. Writes a "hello world" message to an S3 bucket
3. Returns both a direct S3 URL and a CloudFront URL to access the file

## Project Structure

```
lambda-s3-project/
├── .env                      # Environment variables
├── .env-template             # Template for environment variables
├── .gitignore                # Git ignore file
├── README.md                 # Project documentation (this file)
├── package.json              # Node.js dependencies
├── tsconfig.json             # TypeScript configuration
├── jest.config.js            # Jest configuration for testing
├── _deploy                   # Script to deploy the project
├── _destroy                  # Script to destroy AWS infrastructure
├── _ping-endpoint            # Script to test the deployed endpoint
├── _test-local               # Script to run local tests
├── docker/
│   ├── Dockerfile            # Docker image definition for build environment
│   └── build.sh              # Script to build the project inside Docker
├── src/
│   ├── index.ts              # Lambda function entry point
│   ├── s3Service.ts          # S3 interaction logic
│   └── types.ts              # TypeScript type definitions
├── test/
│   ├── index.test.ts         # Tests for the Lambda function
│   └── mock/                 # Mocks for AWS services
│       └── event.json        # Mock API Gateway event
└── infrastructure/
    ├── main.tf               # Main OpenTofu configuration
    ├── variables.tf          # OpenTofu variables
    ├── outputs.tf            # OpenTofu outputs
    └── provider.tf           # AWS provider configuration
```

## Prerequisites

- Docker installed and running
- AWS account with appropriate permissions
- OpenTofu installed (or Terraform)
- Node.js and npm installed locally
- AWS CLI configured (optional, but helpful for troubleshooting)

## Setup Instructions

1. Clone the repository
2. Create a `.env` file with the required environment variables (see .env-template)
3. Install dependencies:
   ```bash
   npm install
   ```
4. Build the Docker image and package:
   ```bash
   npm run build
   ```
5. Test locally:
   ```bash
   npm test
   ```
6. Deploy to AWS:
   ```bash
   npm run deploy
   ```
7. Test the deployed endpoint:
   ```bash
   ./_ping-endpoint
   ```
8. To remove all AWS resources:
   ```bash
   npm run destroy
   ```

## Usage Guide

Here's a quick reference for the available npm scripts:

- `npm run build:docker` - Create the Docker image for building
- `npm run build:package` - Create the Lambda package zip
- `npm run build` - Build both Docker image and Lambda package
- `npm run test` - Run TypeScript compiler and Jest tests
- `npm run deploy` - Deploy to AWS (builds package first)
- `npm run destroy` - Remove all AWS resources
- `npm run all` - Complete build and deploy workflow

## Environment Variables

The following environment variables should be defined in the `.env` file:

- `AWS_REGION`: AWS region (e.g., us-east-1)
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `S3_BUCKET_NAME`: Name of the S3 bucket to create and use
- `S3_FILE_PREFIX`: Prefix for files in S3 (default: hello-world)
- `CLOUDFRONT_PRICE_CLASS`: CloudFront price class (default: PriceClass_100)
- `API_GATEWAY_STAGE`: API Gateway stage name (default: prod)

## How it Works

1. The Lambda function is triggered by a GET request to the API Gateway endpoint
2. It generates a timestamp and creates a text file with a "Hello World" message
3. The file is uploaded to the S3 bucket with public read permissions
4. The function returns a JSON response with:
   - A message confirming successful upload
   - A direct S3 URL to access the file
   - A CloudFront URL to access the file (with caching)
   - The timestamp

## OpenTofu Infrastructure

The OpenTofu configuration creates:

1. S3 bucket for storing the files
2. IAM role for the Lambda function with S3 read/write permissions
3. Lambda function deployment
4. API Gateway to expose the Lambda function
5. CloudFront distribution pointing to the S3 bucket

## Local Testing

The local testing script:

1. Builds the TypeScript code in Docker
2. Runs unit tests using Jest
3. Sets up environment variables for local development
4. Invokes the function with a mock API Gateway event

## Deployment

The deployment script:

1. Builds and packages the Lambda function in Docker
2. Initializes OpenTofu
3. Applies the OpenTofu configuration
4. Outputs the API Gateway URL

## Troubleshooting

If you encounter issues:

- Check AWS credentials in `.env` file
- Ensure Docker is running
- Verify OpenTofu is installed
- Check for permissions issues in AWS
- Look for errors in CloudWatch Logs

## License

MIT
