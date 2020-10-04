const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class City extends Model {}

City.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    taxiPrice: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "taxi_price",
    },
  },
  { sequelize, tableName: "city", timestamps: false }
);
