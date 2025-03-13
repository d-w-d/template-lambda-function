/**
 * Response structure for the Lambda function
 */
export interface ILambdaResponse {
  message: string;
  s3Url: string;
  cloudfrontUrl: string;
  timestamp: string;
}
