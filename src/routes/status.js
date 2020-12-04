const { app } = require("../app");
const middleware = require("../middlewares/auth");
const statusController = require("../controllers/status");

app.get("/api/status/server", statusController.serverStatus);
app.get("/api/status/token", middleware.auth, statusController.tokenStatus);
