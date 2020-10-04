const { Sequelize } = require("sequelize");
const { env } = require("../config/env");

const sequelize = new Sequelize(env.dbUrl);
exports.sequelize = sequelize;

require("../models/log");

(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync({ force: env.test });
    console.log("Connection has been established successfully.");
  } catch (err) {
    console.error(`In db.js anonymous function  Error ${err}`);
  }
})();
