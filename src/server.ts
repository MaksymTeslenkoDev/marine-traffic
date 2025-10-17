import {initApp} from "./app";

const a = "hello";
function sayHi(name: string) {
  const port = 8081;
  initApp(port);
  console.log(`${a} ${name[0].toUpperCase() + name.split("").splice(1).join("")}`);
}

sayHi("nick");
