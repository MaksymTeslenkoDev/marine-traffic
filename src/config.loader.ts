import {AppConfig} from "./config";

export default function loadConfig(): AppConfig {
  // Placeholder for actual configuration loading logic
  return {port: 8081, host: "0.0.0.0", logger: {logLevel: "info", pretty: true}};
}
