import fastify from "fastify";

import {app} from "./app";
import loadConfig from "./config.loader";
import serverOptions from "./config/server-options";

function server() {
  const appPath = process.cwd();
  const config = loadConfig();
  const application = fastify(serverOptions(config));

  application.addHook("onRoute", () => {
    application.log.info("A new route was added");
  });

  application
    .register(app, {config, appPath})
    .listen({port: config.port, host: config.host})
    .then(() => application.log.info(application.printRoutes({commonPrefix: false})))
    .catch((err) => {
      application.log.error(err);
      process.exit(1);
    });
}
server();
