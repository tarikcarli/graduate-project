const { app } = require("../app");
const userController = require("../controllers/user");

app.post("/api/user/register", userController.register);

app.post("/api/user/login", userController.login);

app.post("/api/user/operator/assign", userController.assignOperator);

app.post("/api/user/operator/unassign", userController.unassignOperator);

app.put("/api/user/update/role", userController.updateRole);

app.put("/api/user/update/password", userController.updatePassword);

app.put("/api/user/update", userController.update);

app.post("/api/user/logout", userController.logout);

app.get("/api/user/operators", userController.getOperators);

app.get("/api/user/operatorIds", userController.getOperatorIds);

app.get("/api/user/admin", userController.getAdmin);

app.get("/api/user/all", userController.getAllUser);

app.get("/api/user/me", userController.getMe);

app.delete("/api/user/operator", userController.deleteOperator);
