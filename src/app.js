const path = require("path");
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const bodyParser = require("body-parser");
require("./connections/redis");
require("./connections/rabitmq");
require("./connections/postgres");
// const { auth } = require("./middlewares/auth");
const response = require("./utilities/response");

const app = express();
exports.app = app;

app.use(cors());

app.use(morgan("dev"));

app.use(express.static(path.join(__dirname, "public")));

app.use(bodyParser.urlencoded({ extended: false }));

app.use(bodyParser.json({ limit: "5mb" }));

require("./routes/user");

app.get("/", (req, res) => {
  res.status(200).send("Graduation Project Aykut Akdeniz and Tarik Carli");
});

app.use("*", (req, res, next) => {
  console.log(`404 Not Found Handler Execute`);
  const options = {
    message: "Not Found",
    status: 404,
  };
  return response(options, req, res, next);
});

app.use((err, req, res, next) => {
  console.log(`Global Error Handler Invoke Error: ${err}`);
  const options = {
    message: "Internal Server Error",
    status: 500,
  };
  return response(options, req, res, next);
});
