const { Sequelize } = require("sequelize");
const cities = require("../constants/city.json");
const configs = require("../constants/configs");

const sequelize = new Sequelize(configs.postgres.url, {
  dialectOptions: {
    useUTC: true,
  },
});
exports.sequelize = sequelize;
exports.db = sequelize.models;
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
db.User.hasMany(db.User, {
  foreignKey: "companyId",
  as: "Workers",
});

db.User.belongsTo(db.User, {
  foreignKey: "companyId",
  as: "Company",
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
  as: "BusinessCompany",
});

db.User.hasMany(db.Business, {
  foreignKey: "workerId",
  as: "WorkerBusiness",
});
db.Business.belongsTo(db.User, {
  foreignKey: "workerId",
  as: "BusinessWorker",
});

// Location associations
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
  foreignKey: "locationBeginId",
  as: "BeginLocation",
});
db.TaxiInvoice.belongsTo(db.Location, {
  foreignKey: "locationBeginId",
  as: "LocationBegin",
});

db.Location.hasOne(db.TaxiInvoice, {
  foreignKey: "locationEndId",
  as: "EndLocation",
});
db.TaxiInvoice.belongsTo(db.Location, {
  foreignKey: "locationEndId",
  as: "LocationEnd",
});

db.Location.hasOne(db.City, {
  foreignKey: "locationId",
});
db.City.belongsTo(db.Location, {
  foreignKey: "locationId",
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
function populateCity() {
  cities.forEach(async (city) => {
    const location = await db.Location.create({
      latitude: city.latitude,
      longitude: city.longitude,
    });
    await db.City.create({
      locationId: location.dataValues.id,
      name: city.name,
      taxiPrice: 5,
      startingPrice: 5,
    });
  });
}
(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync({ force: configs.test });
    console.log("Connection has been established successfully.");
    if (configs.test) {
      populateCity();
    }
  } catch (err) {
    console.error(`In db.js anonymous function  Error ${err}`);
  }
})();
