import {FastifyPluginAsync} from "fastify";

import {AppConfig} from "./config";
import root from "./routes/root";

export const app: FastifyPluginAsync<{config: AppConfig; appPath: string}> = async (
  fastify,
): Promise<void> => {
  fastify.register(root, {prefix: "v1/api/"});
};
