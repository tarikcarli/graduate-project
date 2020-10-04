require("./connections/rabitmq");
require("./connections/db");
const path = require("path");
const express = require("express");

const app = express();
exports.app = app;

app.use(express.static(path.join(__dirname, "public")));

app.get("/", (req, res) => {
  res.send("Hello World!");
});
