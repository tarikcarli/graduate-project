const { app } = require("../app");
const workerController = require("../controllers/worker");
const middleware = require("../middlewares/auth");

// app.get(
//   "/api/worker/invoice",
//   middleware.auth,
//   middleware.onlyWorker,
//   workerController.getInvoice
// );
// app.get(
//   "/api/worker/business",
//   middleware.auth,
//   middleware.onlyWorker,
//   workerController.getBusiness
// );

app.post(
  "/api/worker/register",
  middleware.auth,
  middleware.onlyCompany,
  workerController.register
);

// app.post(
//   "/api/worker/location",
//   middleware.auth,
//   middleware.onlyWorker,
//   workerController.postLocation
// );

// app.post(
//   "/api/worker/locations",
//   middleware.auth,
//   middleware.onlyWorker,
//   workerController.postLocations
// );

// app.get(
//   "/api/user/location/history/",
//   middleware.auth,
//   userController.getHistoryLocation
// );

// app.post(
//   "/api/worker/invoice",
//   middleware.auth,
//   middleware.onlyWorker,
//   workerController.postInvoice
// );
