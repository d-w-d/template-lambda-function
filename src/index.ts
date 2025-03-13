import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { S3Service } from "./s3Service";
import { LambdaResponse, ErrorResponse } from "./types";

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

    // Generate timestamp
    const timestamp = new Date().toISOString();
    const content = `Hello World! Generated at ${timestamp}`;
    const key = `${filePrefix}-${timestamp}.txt`;

    // Upload to S3
    await s3Service.uploadFile(key, content);

    // Generate URLs
    const s3Url = s3Service.getSignedUrl(key);
    const cloudfrontUrl = s3Service.getCloudfrontUrl(key);

    // Create response
    const response: LambdaResponse = {
      message: "File successfully uploaded",
      s3Url,
      cloudfrontUrl,
      timestamp,
    };

    // Return success response
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(response),
    };
  } catch (error) {
    console.error("Error in Lambda function:", error);

    // Create error response
    const errorResponse: ErrorResponse = {
      message: "Error processing request",
      error: (error as Error).message,
    };

    // Return error response
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(errorResponse),
    };
  }
};
