const { app } = require("../app");
const locationController = require("../controllers/location");

app.post("/api/location", locationController.postLocation);

app.get("/api/location", locationController.getLocation);
