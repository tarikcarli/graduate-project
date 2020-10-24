const { app } = require("../app");
const businessController = require("../controllers/business");

app.get("/api/business", businessController.getBusiness);

app.post("/api/business", businessController.postBusiness);
