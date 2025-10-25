import {FastifyInstance} from "fastify";

export default function rootRoutes(fastify: FastifyInstance) {
  fastify.route({
    url: "/ping",
    method: "POST",
    handler: async function pingHandler({log}) {
      log.info("Ping received");
      return "pong";
    },
  });
}
