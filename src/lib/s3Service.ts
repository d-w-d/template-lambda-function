import { S3 } from "aws-sdk";
import { IS3Config } from "../models/IS3Config";

/**
 * Service for interacting with AWS S3
 */
export class S3Service {
  private readonly s3: S3;
  private readonly bucketName: string;
  private readonly cloudfrontDomain: string;

  constructor(bucketName: string) {
    // Use the default credential provider chain instead of explicit credentials
    this.s3 = new S3({
      region: process.env.AWS_REGION || "us-east-1",
    });
    this.bucketName = bucketName;
    this.cloudfrontDomain = process.env.CLOUDFRONT_DOMAIN || "";
  }

  /**
   * Upload a text file to S3
   * @param key - The S3 object key
   * @param content - The content to upload
   * @returns Promise that resolves when upload is complete
   */
  async uploadFile(key: string, content: string): Promise<void> {
    const params: S3.PutObjectRequest = {
      Bucket: this.bucketName,
      Key: key,
      Body: content,
      ContentType: "text/plain",
      // ACL: "public-read", // Remove ACL setting as modern buckets disable ACLs
    };

    await this.s3.putObject(params).promise();
  }

  /**
   * Get a signed URL to access the S3 object
   * @param key - The S3 object key
   * @returns The S3 URL
   */
  getSignedUrl(key: string): string {
    // For public files, we can simply construct the URL
    return `https://${this.bucketName}.s3.amazonaws.com/${key}`;
  }

  /**
   * Get a CloudFront URL for the S3 object
   * @param key - The S3 object key
   * @returns The CloudFront URL
   */
  getCloudfrontUrl(key: string): string {
    return `https://${this.cloudfrontDomain}/${key}`;
  }

  /**
   * Get the current configuration of this S3 service
   * @returns The S3 configuration
   */
  getConfig(): IS3Config {
    return {
      bucketName: this.bucketName,
      filePrefix: process.env.S3_FILE_PREFIX || "",
      cloudfrontDomain: this.cloudfrontDomain,
    };
  }
}
