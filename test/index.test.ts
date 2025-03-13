import { handler } from "../src/index";
import { S3 } from "aws-sdk";
import * as eventJson from "./mock/event.json";
import * as dotenv from "dotenv";
import * as path from "path";

// Load environment variables from .env file with explicit path
dotenv.config({ path: path.resolve(__dirname, "../.env") });

// Mock AWS SDK
jest.mock("aws-sdk", () => {
  const mS3 = {
    putObject: jest.fn().mockReturnThis(),
    promise: jest.fn().mockResolvedValue({}),
  };
  return {
    S3: jest.fn(() => mS3),
  };
});

describe("Lambda Handler", () => {
  beforeEach(() => {
    // Ensure environment variables are set for tests, with fallbacks to values in .env if loaded
    process.env.S3_BUCKET_NAME = process.env.S3_BUCKET_NAME || "test-bucket";
    process.env.S3_FILE_PREFIX = process.env.S3_FILE_PREFIX || "test-prefix";

    // We don't need CLOUDFRONT_DOMAIN for unit testing
    process.env.AWS_ACCESS_KEY_ID =
      process.env.AWS_ACCESS_KEY_ID || "test-access-key";
    process.env.AWS_SECRET_ACCESS_KEY =
      process.env.AWS_SECRET_ACCESS_KEY || "test-secret-key";
    jest.clearAllMocks();
  });

  it("should upload to S3 and return URLs", async () => {
    const result = await handler(eventJson as any);

    //
    console.log("Result:", result);

    // Check if S3 putObject was called
    const s3Instance = new S3();
    expect(s3Instance.putObject).toHaveBeenCalled();

    // Check response structure
    expect(result.statusCode).toBe(200);
    expect(result.headers!["Content-Type"]).toBe("application/json");

    const body = JSON.parse(result.body);
    expect(body.message).toBe("File successfully uploaded");
    expect(body.s3Url).toContain(
      `${process.env.S3_BUCKET_NAME}.s3.amazonaws.com`
    );
    // Don't test the specific cloudfront URL since that's not part of the unit test scope
    expect(body.timestamp).toBeDefined();
  });

  it("should handle errors gracefully", async () => {
    // Store original value to restore later
    const originalBucketName = process.env.S3_BUCKET_NAME;

    // Force an error by removing required env var
    delete process.env.S3_BUCKET_NAME;

    const result = await handler(eventJson as any);

    // Restore the environment variable
    process.env.S3_BUCKET_NAME = originalBucketName;

    expect(result.statusCode).toBe(500);
    const body = JSON.parse(result.body);
    expect(body.message).toBe("Error processing request");
    expect(body.error).toBeDefined();
  });
});
