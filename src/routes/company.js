const { app } = require("../app");
const companyController = require("../controllers/company");
const { onlyCompany } = require("../middlewares/auth");

app.get("/api/company/workers", onlyCompany, companyController.getWorkers);

// app.get(
//   "/api/company/invoice",
//   middleware.auth,
//   middleware.onlyCompany,
//   companyController.getInvoice
// );

// app.get(
//   "/api/company/business",
//   middleware.auth,
//   middleware.onlyCompany,
//   companyController.getBusiness
// );

// app.get(
//   "/api/company/location/current",
//   middleware.auth,
//   middleware.onlyCompany,
//   companyController.getLocation
// );

// app.post(
//   "/api/company/business",
//   middleware.auth,
//   middleware.onlyCompany,
//   companyController.postBusiness
// );
