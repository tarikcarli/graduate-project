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
    locationId: {
      type: DataTypes.INTEGER,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    startingPrice: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    taxiPrice: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  { sequelize, tableName: "city", timestamps: false }
);
