const { app } = require("../app");
const taskController = require("../controllers/task");

app.get("/api/task", taskController.getTask);

app.post("/api/task", taskController.postTask);

app.put("/api/task", taskController.putTask);

app.delete("/api/task", taskController.deleteTask);
