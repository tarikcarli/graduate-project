const { app } = require("../app");
const userLocationController = require("../controllers/userLocation");

app.post("/api/user/location", userLocationController.postLocation);

app.post("/api/user/locations", userLocationController.postLocations);

app.get(
  "/api/user/location/current",
  userLocationController.getCurrentLocation
);

app.get(
  "/api/user/location/history",
  userLocationController.getHistoryLocation
);
