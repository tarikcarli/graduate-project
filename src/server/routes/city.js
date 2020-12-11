const { app } = require("../app");
const cityController = require("../controllers/city");

app.get("/api/city", cityController.getCities);
