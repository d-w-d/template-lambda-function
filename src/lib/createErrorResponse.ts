import { APIGatewayProxyResult } from "aws-lambda";
import { IErrorResponse } from "../models/IErrorResponse";

/**
 * Create an error response object for the Lambda handler.
 */
export const createErrorResponse = (
  error: Error
): APIGatewayProxyResult => {
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
