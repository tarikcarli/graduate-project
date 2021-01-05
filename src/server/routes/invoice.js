const { app } = require("../app");
const invoiceController = require("../controllers/invoice");

app.get("/api/invoice", invoiceController.getInvoice);

app.post("/api/invoice", invoiceController.postInvoice);

app.put("/api/invoice", invoiceController.putInvoice);

app.post("/api/invoice/sendmail",invoiceController.sendMail);