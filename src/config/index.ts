export const logLevelTypes = {
  INFO: "info",
  DEBUG: "debug",
  ERROR: "error",
  TRACE: "trace",
} as const;
type LogLevel = (typeof logLevelTypes)[keyof typeof logLevelTypes];

export type AppConfig = {port: number; host: string; logger: {logLevel: LogLevel; pretty: boolean}};
