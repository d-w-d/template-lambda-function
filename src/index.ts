import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { S3Service } from "./lib/s3Service";
import { ILambdaResponse } from "./models/ILambdaResponse";
import { IErrorResponse } from "./models/IErrorResponse";

/**
 * Create content for the S3 file with a timestamp
 * @returns Object containing content and key
 */
const createFileContent = (
  filePrefix: string
): { content: string; key: string; timestamp: string } => {
  const timestamp = new Date().toISOString();
  const content = `Hello World! Generated at ${timestamp}`;
  const key = `${filePrefix}-${timestamp}.txt`;

  return { content, key, timestamp };
};

/**
 * Create a success response object
 * @param s3Url The S3 URL
 * @param cloudfrontUrl The CloudFront URL
 * @param timestamp The timestamp
 * @returns The formatted Lambda response
 */
const createSuccessResponse = (
  s3Url: string,
  cloudfrontUrl: string,
  timestamp: string
): APIGatewayProxyResult => {
  const response: ILambdaResponse = {
    message: "File successfully uploaded",
    s3Url,
    cloudfrontUrl,
    timestamp,
  };

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(response),
  };
};

/**
 * Create an error response object
 * @param error The error object
 * @returns The formatted error response
 */
const createErrorResponse = (error: Error): APIGatewayProxyResult => {
  const errorResponse: IErrorResponse = {
    message: "Error processing request",
    error: error.message,
  };

  return {
    statusCode: 500,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(errorResponse),
  };
};

/**
 * Lambda function handler
 * Writes a "hello world" message to S3 and returns URLs to access it
 */
export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    // Get environment variables
    const bucketName = process.env.S3_BUCKET_NAME || "";
    const filePrefix = process.env.S3_FILE_PREFIX || "hello-world";

    console.log("Bucket name:", bucketName);
    console.log("File prefix:", filePrefix);

    if (!bucketName) {
      throw new Error("S3_BUCKET_NAME environment variable is required");
    }

    // Create S3 service
    const s3Service = new S3Service(bucketName);

    // Generate content and key
    const { content, key, timestamp } = createFileContent(filePrefix);

    // Upload to S3
    await s3Service.uploadFile(key, content);

    // Generate URLs
    const s3Url = s3Service.getSignedUrl(key);
    const cloudfrontUrl = s3Service.getCloudfrontUrl(key);

    // Return success response
    return createSuccessResponse(s3Url, cloudfrontUrl, timestamp);
  } catch (error) {
    console.error("Error in Lambda function:", error);

    // Return error response
    return createErrorResponse(error as Error);
  }
};
