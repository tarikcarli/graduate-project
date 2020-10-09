const { Sequelize } = require("sequelize");
const { env } = require("../config/env");

const sequelize = new Sequelize(env.dbUrl);
exports.sequelize = sequelize;

require("../models/business");
require("../models/city");
require("../models/invoice");
require("../models/location");
require("../models/log");
require("../models/otherInvoice");
require("../models/photo");
require("../models/taxiInvoice");
require("../models/user");
require("../models/userLocation");
require("../models/workerCompany");

const db = sequelize.models;
// Photo associations
db.Photo.hasOne(db.User, {
  foreignKey: "photo_id",
});
db.User.belongsTo(db.Photo);

db.Photo.hasOne(db.Invoice, {
  foreignKey: "photo_id",
});
db.Invoice.belongsTo(db.Photo);

// City associations
db.City.hasMany(db.Business, {
  foreignKey: "city_id",
});
db.Business.belongsTo(db.City);

// User associations
db.User.hasOne(db.WorkerCompany, {
  foreignKey: "worker_id",
  as: "company",
});
db.WorkerCompany.belongsTo(db.User, {
  as: "workerCompany",
});

db.User.hasMany(db.WorkerCompany, {
  foreignKey: "company_id",
  as: "worker",
});
db.WorkerCompany.belongsTo(db.User, {
  as: "companyWorker",
});

db.User.hasMany(db.UserLocation, {
  foreignKey: "user_id",
});
db.UserLocation.belongsTo(db.User);

db.User.hasMany(db.Business, {
  foreignKey: "company_id",
  as: "companyBusiness",
});
db.Business.belongsTo(db.User);

db.User.hasMany(db.Business, {
  foreignKey: "worker_id",
  as: "workerBusiness",
});
db.Business.belongsTo(db.User);

// Location associations
db.Location.hasOne(db.UserLocation, {
  foreignKey: "location_id",
});
db.UserLocation.belongsTo(db.Location);

db.Location.hasOne(db.Business, {
  foreignKey: "location_id",
});
db.Business.belongsTo(db.Location);

db.Location.hasOne(db.OtherInvoice, {
  foreignKey: "location_id",
});
db.OtherInvoice.belongsTo(db.Location);

db.Location.hasOne(db.TaxiInvoice, {
  foreignKey: "location_begin",
  as: "locationBegin",
});
db.TaxiInvoice.belongsTo(db.Location, {
  as: "beginLocation",
});

db.Location.hasOne(db.TaxiInvoice, {
  foreignKey: "location_end",
  as: "locationEnd",
});
db.TaxiInvoice.belongsTo(db.Location, {
  as: "endLocation",
});

// Business associations
db.Business.hasMany(db.Invoice, {
  foreignKey: "business_id",
});
db.Invoice.belongsTo(db.Business);

// Invoice associations
db.Invoice.hasOne(db.OtherInvoice, {
  foreignKey: "invoice_id",
});
db.OtherInvoice.belongsTo(db.Invoice);

db.Invoice.hasOne(db.TaxiInvoice, {
  foreignKey: "invoice_id",
});
db.TaxiInvoice.belongsTo(db.Invoice);

(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync({ force: env.test });
    console.log("Connection has been established successfully.");
  } catch (err) {
    console.error(`In db.js anonymous function  Error ${err}`);
  }
})();
