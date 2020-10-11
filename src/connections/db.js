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
  foreignKey: "photoId",
});
db.User.belongsTo(db.Photo, {
  foreignKey: "photoId",
});

db.Photo.hasOne(db.Invoice, {
  foreignKey: "photoId",
});
db.Invoice.belongsTo(db.Photo, {
  foreignKey: "photoId",
});

// City associations
db.City.hasMany(db.Business, {
  foreignKey: "cityId",
});
db.Business.belongsTo(db.City, {
  foreignKey: "cityId",
});

// User associations
db.User.hasOne(db.WorkerCompany, {
  foreignKey: "workerId",
  as: "Company",
});
db.WorkerCompany.belongsTo(db.User, {
  foreignKey: "workerId",
  as: "CompanyWorker",
});

db.User.hasMany(db.WorkerCompany, {
  foreignKey: "companyId",
  as: "Worker",
});
db.WorkerCompany.belongsTo(db.User, {
  as: "WorkerCompany",
  foreignKey: "companyId",
});

db.User.hasMany(db.UserLocation, {
  foreignKey: "userId",
});
db.UserLocation.belongsTo(db.User, {
  foreignKey: "userId",
});

db.User.hasMany(db.Business, {
  foreignKey: "companyId",
  as: "CompanyBusiness",
});
db.Business.belongsTo(db.User, {
  foreignKey: "companyId",
});

db.User.hasMany(db.Business, {
  foreignKey: "workerId",
  as: "WorkerBusiness",
});
db.Business.belongsTo(db.User, {
  foreignKey: "workerId",
});

// Location associations
db.Location.hasOne(db.UserLocation, {
  foreignKey: "locationId",
});
db.UserLocation.belongsTo(db.Location, {
  foreignKey: "locationId",
});

db.Location.hasOne(db.Business, {
  foreignKey: "locationId",
});
db.Business.belongsTo(db.Location, {
  foreignKey: "locationId",
});

db.Location.hasOne(db.OtherInvoice, {
  foreignKey: "locationId",
});
db.OtherInvoice.belongsTo(db.Location, {
  foreignKey: "locationId",
});

db.Location.hasOne(db.TaxiInvoice, {
  foreignKey: "locationBegin",
  as: "LocationBegin",
});
db.TaxiInvoice.belongsTo(db.Location, {
  foreignKey: "locationBegin",
  as: "BeginLocation",
});

db.Location.hasOne(db.TaxiInvoice, {
  foreignKey: "locationEnd",
  as: "LocationEnd",
});
db.TaxiInvoice.belongsTo(db.Location, {
  foreignKey: "locationEnd",
  as: "EndLocation",
});

// Business associations
db.Business.hasMany(db.Invoice, {
  foreignKey: "businessId",
});
db.Invoice.belongsTo(db.Business, {
  foreignKey: "businessId",
});

// Invoice associations
db.Invoice.hasOne(db.OtherInvoice, {
  foreignKey: "invoiceId",
});
db.OtherInvoice.belongsTo(db.Invoice, {
  foreignKey: "invoiceId",
});

db.Invoice.hasOne(db.TaxiInvoice, {
  foreignKey: "invoiceId",
});
db.TaxiInvoice.belongsTo(db.Invoice, {
  foreignKey: "invoiceId",
});

(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync({ force: env.test });
    console.log("Connection has been established successfully.");
  } catch (err) {
    console.error(`In db.js anonymous function  Error ${err}`);
  }
})();
