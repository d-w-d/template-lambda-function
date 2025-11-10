import { APIGatewayProxyResult } from "aws-lambda";
import { ILambdaResponse } from "../models/ILambdaResponse";

/**
 * Create a success response object for the Lambda handler.
 */
export const createSuccessResponse = (
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
