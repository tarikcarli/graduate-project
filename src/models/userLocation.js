const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class UserLocation extends Model {}

UserLocation.init(
  {
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    locationId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      unique: true,
    },
  },
  { sequelize, tableName: "user_location", timestamps: false }
);
