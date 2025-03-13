/**
 * Configuration for the S3 service
 */
export interface IS3Config {
  bucketName: string;
  filePrefix: string;
  cloudfrontDomain: string;
}
