const path = require("path");
const express = require("express");
const bodyParser = require("body-parser");
const { insertDb } = require("./middlewares/auth");
require("./connections/redis");
require("./connections/rabitmq");
require("./connections/db");

const app = express();
exports.app = app;

app.use(express.static(path.join(__dirname, "public")));

app.use(bodyParser.urlencoded({ extended: false }));

app.use(bodyParser.json({ limit: "5mb" }));

app.use(insertDb);

require("./routes/user");
require("./routes/company");
require("./routes/worker");

app.get("/", (req, res) => {
  res.status(200).send("Graduate Project Aykut Akdeniz and Tarik Carli");
});

app.use("*", (req, res) => {
  res.status(404).json({ message: "Restful Endpoint Not Found" });
});

app.use((err, req, res, _next) => {
  console.log(`Global Error Handler Invoke Error: ${err}`);
  return res.status(500).json({ message: "Internal Server Error" });
});
