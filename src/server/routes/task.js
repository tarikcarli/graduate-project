const { app } = require("../app");
const taskController = require("../controllers/task");

app.get("/api/task", taskController.getBusiness);

app.post("/api/task", taskController.postBusiness);

app.put("/api/task", taskController.putBusiness);
