const { app } = require("../app");
const userController = require("../controllers/user");

app.get("/user/login", userController.login);

app.patch("/user/password", userController.changePassword);

app.patch("/user/photo", userController.changePhoto);

app.patch("/user/info", userController.changeInfo);

app.get("/user/status", userController.tokenStatus);

app.get("/server/status", userController.serverStatus);
