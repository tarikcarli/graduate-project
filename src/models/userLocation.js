const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class UserLocation extends Model {}

UserLocation.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId:{
      type:DataTypes.INTEGER,
      allowNull:false,
    },
    latitude: {
      type: DataTypes.DOUBLE,
      allowNull: false,
    },
    longitude: {
      type: DataTypes.DOUBLE,
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
