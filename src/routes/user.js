const { app } = require("../app");
const userController = require("../controllers/user");

app.post("/api/user/logout", userController.logout);

app.put("/api/user/update", userController.update);

app.get("/api/user/status", userController.tokenStatus);
