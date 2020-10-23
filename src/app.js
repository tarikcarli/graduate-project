const path = require("path");
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const bodyParser = require("body-parser");
const { auth } = require("./middlewares/auth");
const { login, serverStatus } = require("./controllers/user");
const { register } = require("./controllers/company");
const response = require("./utilities/response");
require("./connections/redis");
require("./connections/rabitmq");
require("./connections/db");

const app = express();
exports.app = app;

app.use(cors());

app.use(morgan("dev"));

app.use(express.static(path.join(__dirname, "public")));

app.use(bodyParser.urlencoded({ extended: false }));

app.use(bodyParser.json({ limit: "5mb" }));

app.post("/api/user/login", login);
app.post("/api/company/register", register);
app.get("/api/server/status", serverStatus);

app.use(auth);

require("./routes/user");
require("./routes/company");
require("./routes/worker");

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
