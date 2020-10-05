const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class UserLocation extends Model {}

UserLocation.init(
  {
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "user_id",
    },
    locationId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      unique: true,
      field: "location_id",
    },
  },
  { sequelize, tableName: "user_location", timestamps: false }
);
