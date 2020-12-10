const { app } = require("../app");
const locationController = require("../controllers/location");

app.post("/api/location", locationController.postLocation);

app.post("/api/user/location", locationController.postUserLocation);

app.post("/api/user/locations", locationController.postUserLocations);

app.get("/api/location", locationController.getLocation);

app.get("/api/user/location/current", locationController.getCurrentLocation);

app.get("/api/user/location/history", locationController.getHistoryLocation);
