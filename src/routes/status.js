const { app } = require("../app");
const statusController = require("../controllers/status");

app.get("/api/status", statusController.serverStatus);
