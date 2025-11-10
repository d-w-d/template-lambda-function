interface ILoggerOptions {
  level?: "INFO" | "WARN" | "ERROR";
  requestId?: string;
  userId?: string;
  metadata?: Record<string, unknown>;
}

/**
 * Emit a structured JSON log for CloudWatch.
 */
export function logger(message: string, options: ILoggerOptions = {}): void {
  const payload = {
    timestamp: new Date().toISOString(),
    level: options.level ?? "INFO",
    message,
    requestId: options.requestId ?? "unknown",
    userId: options.userId ?? "anonymous",
    metadata: options.metadata ?? {},
  };

  console.log(JSON.stringify(payload));
}
