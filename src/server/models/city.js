const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/postgres");

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
    priceInitial: {
      type: DataTypes.DOUBLE,
      allowNull: false,
    },
    pricePerKm: {
      type: DataTypes.DOUBLE,
      allowNull: false,
    },
  },
  { sequelize, tableName: "city", timestamps: false }
);
