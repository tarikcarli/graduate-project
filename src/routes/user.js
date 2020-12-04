const { app } = require("../app");
const userController = require("../controllers/user");

app.post("/api/user/register", userController.register);

app.put("/api/user/update", userController.update);

app.post("/api/user/login", userController.login);

app.post("/api/user/logout", userController.logout);

app.get("/api/user/company/workers", userController.getWorkers);

app.get("/api/user/worker/company", userController.getAdmin);
