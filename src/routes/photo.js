const { app } = require("../app");
const photoController = require("../controllers/photo");

app.get("/api/photo/", photoController.getPhoto);
