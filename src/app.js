const path = require("path");
const express = require("express");
require("./connections/redis");
require("./connections/rabitmq");
require("./connections/db");

const app = express();
exports.app = app;

app.use(express.static(path.join(__dirname, "public")));

app.get("/", (req, res) => {
  res.send("Hello World!");
});
