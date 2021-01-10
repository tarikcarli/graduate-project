/* eslint-disable global-require */
const fs = require("fs");
const { Sequelize } = require("sequelize");
const configs = require("../constants/configs");
let sequelize;

if(configs.PRODUCTION){
  sequelize = new Sequelize(configs.POSTGRES_URL, {
    dialect:"postgres",
    ssl: true,
    dialectOptions: {
      useUTC: true,
      ssl: {
        ca: fs.readFileSync(`${process.cwd()}/ca-certificate.crt`),
      },
    },
  });
} else {
  sequelize = new Sequelize(configs.POSTGRES_URL, {
    dialect:"postgres",
    dialectOptions: {
      useUTC: true,
    },
  });
}

exports.sequelize = sequelize;
exports.db = sequelize.models;

require("../models/task");
require("../models/city");
require("../models/invoice");
require("../models/location");
require("../models/log");
require("../models/photo");
require("../models/user");
require("../models/joinUserLocation");
require("../models/joinUserUser");

const db = sequelize.models;
// PHOTO_TO_USER associations
db.Photo.hasOne(db.User, {
  foreignKey: "photoId",
});
db.User.belongsTo(db.Photo, {
  foreignKey: "photoId",
});

// PHOTO_TO_INVOICE associations
db.Photo.hasOne(db.Invoice, {
  foreignKey: "photoId",
});
db.Invoice.belongsTo(db.Photo, {
  foreignKey: "photoId",
});

// CITY_TO_TASK associations
db.City.hasMany(db.Invoice, {
  foreignKey: "cityId",
});
db.Invoice.belongsTo(db.City, {
  foreignKey: "cityId",
});

// USER_TO_USER associations
db.User.hasMany(db.UserUser, {
  foreignKey: "adminId",
  as: "admin",
});

db.UserUser.belongsTo(db.User, {
  foreignKey: "adminId",
  as: "admin",
});

db.User.hasOne(db.UserUser, {
  foreignKey: "operatorId",
  as: "operator",
});
db.UserUser.belongsTo(db.User, {
  foreignKey: "operatorId",
  as: "operator",
});
// USER_TO_INVOICE associations
db.User.hasMany(db.Invoice, {
  foreignKey: "adminId",
  as: "adminInvoice",
});

db.Invoice.belongsTo(db.User, {
  foreignKey: "adminId",
  as: "adminInvoice",
});

db.User.hasOne(db.Invoice, {
  foreignKey: "operatorId",
  as: "operatorInvoice",
});
db.Invoice.belongsTo(db.User, {
  foreignKey: "operatorId",
  as: "operatorInvoice",
});

// USER_TO_LOCATION associations
db.User.hasMany(db.UserLocation, {
  foreignKey: "operatorId",
});
db.UserLocation.belongsTo(db.User, {
  foreignKey: "operatorId",
});
// USER_TO_TASK associations
db.User.hasMany(db.Task, {
  foreignKey: "adminId",
  as: "adminTasks",
});
db.Task.belongsTo(db.User, {
  foreignKey: "adminId",
  as: "adminTasks",
});

db.User.hasMany(db.Task, {
  foreignKey: "operatorId",
  as: "operatorTasks",
});
db.Task.belongsTo(db.User, {
  foreignKey: "operatorId",
  as: "operatorTasks",
});

// LOCATION_TO_USER associations
db.Location.hasOne(db.UserLocation, {
  foreignKey: "locationId",
});
db.UserLocation.belongsTo(db.Location, {
  foreignKey: "locationId",
});

// LOCATION_TO_TASK associations
db.Location.hasOne(db.Task, {
  foreignKey: "locationId",
});
db.Task.belongsTo(db.Location, {
  foreignKey: "locationId",
});

// LOCATION_TO_INVOICE associations
db.Location.hasOne(db.Invoice, {
  foreignKey: "beginLocationId",
  as: "beginLocation",
});
db.Invoice.belongsTo(db.Location, {
  foreignKey: "beginLocationId",
  as: "beginLocation",
});

db.Location.hasOne(db.Invoice, {
  foreignKey: "endLocationId",
  as: "endLocation",
});
db.Invoice.belongsTo(db.Location, {
  foreignKey: "endLocationId",
  as: "endLocation",
});

// TASK_TO_INVOICE associations
db.Task.hasMany(db.Invoice, {
  foreignKey: "taskId",
});
db.Invoice.belongsTo(db.Task, {
  foreignKey: "taskId",
});

(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync({ force: configs.RECREATE_DB });
    console.log("Connection has been established successfully.");
    if(configs.RECREATE_DB){
      if (configs.LOAD_DUMMY_DATA) {
        require("../utilities/populateDb")();
      } else {
        await db.User.create({
          "photoId": null,
          "role": "system",
          "name": "Aykut Akdeniz",
          "email": "aykutakdeniz@gmail.com",
          "password": await db.User.hashPassword("12345678"),
        });
        const cities = require('../constants/db_data.json').cities;
        await db.City.bulkCreate(cities);
      }
    }
  } catch (err) {
    console.error(`In db.js anonymous function  Error ${err}`);
  }
})();
