const { app } = require("../app");
const locationController = require("../controllers/location");

app.get("/api/location", locationController.getLocation);

app.post("/api/location", locationController.postLocation);
