/**
 *
 * @param message
 * @param context
 * @param level
 * @param metadata
 * @param user
 * @param XRay
 */
export function logger(
  message: string,
  context: any,
  level: string = "INFO",
  user: { id: string } = { id: "anonymous" },
  XRay: any
): void {
  console.log(
    JSON.stringify({
      timestamp: new Date().toISOString(),
      message,
      requestId: context.awsRequestId,
      level,
      userId: user.id,
      traceId: XRay.getTraceId(),
    })
  );
}
