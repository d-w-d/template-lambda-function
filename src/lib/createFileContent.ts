/**
 * Create content for the S3 file with a timestamp.
 */
export const createFileContent = (
  filePrefix: string
): { content: string; key: string; timestamp: string } => {
  const timestamp = new Date().toISOString();
  const content = `Hello World! Generated at ${timestamp}`;
  const key = `${filePrefix}-${timestamp}.txt`;

  return { content, key, timestamp };
};
