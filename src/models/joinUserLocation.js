const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/postgres");

class UserLocation extends Model {}

UserLocation.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    operatorId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    locationId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    sequelize,
    tableName: "user_location",
    timestamps: true,
    updatedAt: false,
  }
);
