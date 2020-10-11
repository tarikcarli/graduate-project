const { app } = require("../app");
const userController = require("../controllers/user");
const middleware = require("../middlewares/auth");

app.post("/api/user/login", userController.login);

app.post("/api/user/logout", middleware.auth, userController.logout);

app.put("/api/user/update", middleware.auth, userController.update);

app.get("/api/user/status", middleware.auth, userController.tokenStatus);

app.get("/api/server/status", userController.serverStatus);
