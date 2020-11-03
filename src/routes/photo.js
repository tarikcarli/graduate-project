const { app } = require("../app");
const photoController = require("../controllers/photo");

app.get("/api/photo/", photoController.getPhoto);

app.post("/api/photo/", photoController.postPhoto);

app.put("/api/photo/", photoController.putPhoto);
