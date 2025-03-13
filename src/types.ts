/**
 * Type definitions for the Lambda S3 Writer project
 */

/**
 * Response structure for the Lambda function
 */
export interface LambdaResponse {
  message: string;
  s3Url: string;
  cloudfrontUrl: string;
  timestamp: string;
}

/**
 * Error response structure
 */
export interface ErrorResponse {
  message: string;
  error: string;
}

/**
 * Configuration for the S3 service
 */
export interface S3Config {
  bucketName: string;
  filePrefix: string;
  cloudfrontDomain: string;
}
