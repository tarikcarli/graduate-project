const { app } = require("../app");
const locationController = require("../controllers/location");

app.post("/api/worker/location", locationController.postLocation);

app.post("/api/worker/locations", locationController.postLocations);

app.get("/api/user/location/history/", locationController.getHistoryLocation);
