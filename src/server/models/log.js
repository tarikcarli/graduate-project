const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/postgres");

class Log extends Model {}

Log.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
    },
    ip: {
      type: DataTypes.STRING,
    },
    method: {
      type: DataTypes.STRING,
    },
    body: {
      type: DataTypes.TEXT,
    },
    headers: {
      type: DataTypes.TEXT,
    },
    url: {
      type: DataTypes.STRING,
    },
    message: {
      type: DataTypes.TEXT,
    },
    status: {
      type: DataTypes.INTEGER,
    },
  },
  {
    sequelize,
    tableName: "log",
    timestamps: true,
    updatedAt: false,
  }
);

module.exports = Log;
