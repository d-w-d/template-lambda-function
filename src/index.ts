import {
  APIGatewayProxyEvent,
  APIGatewayProxyResult,
  Context,
} from "aws-lambda";
import { S3Service } from "./lib/s3Service";
import { logger } from "./lib/logger";
import { createFileContent } from "./lib/createFileContent";
import { createSuccessResponse } from "./lib/createSuccessResponse";
import { createErrorResponse } from "./lib/createErrorResponse";

/**
 * Lambda function handler
 * Writes a "hello world" message to S3 and returns URLs to access it
 */
export const handler = async (
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  try {
    // Get environment variables
    const bucketName = process.env.S3_BUCKET_NAME || "";
    const filePrefix = process.env.S3_FILE_PREFIX || "hello-world";

    logger("Invocation started", {
      requestId: context.awsRequestId,
      metadata: {
        bucketConfigured: Boolean(bucketName),
        filePrefix,
        resourcePath: event.resource,
      },
    });

    if (!bucketName) {
      throw new Error("S3_BUCKET_NAME environment variable is required");
    }

    // Create S3 service
    const s3Service = new S3Service(bucketName);

    // Generate content and key
    const { content, key, timestamp } = createFileContent(filePrefix);

    // Upload to S3 (timestamped and rolling latest)
    const latestKey = "latest.txt";
    await Promise.all([
      s3Service.uploadFile(key, content),
      s3Service.uploadFile(latestKey, content),
    ]);

    // Generate URLs
    const s3Url = s3Service.getSignedUrl(key);
    const cloudfrontUrl = s3Service.getCloudfrontUrl(key);

    logger("File uploaded", {
      requestId: context.awsRequestId,
      metadata: { key, latestKey, bucketName, s3Url, cloudfrontUrl },
    });

    // Return success response
    return createSuccessResponse(s3Url, cloudfrontUrl, timestamp);
  } catch (error) {
    logger("Error in Lambda function", {
      level: "ERROR",
      requestId: context.awsRequestId,
      metadata: {
        message: (error as Error).message,
      },
    });

    // Return error response
    return createErrorResponse(error as Error);
  }
};
