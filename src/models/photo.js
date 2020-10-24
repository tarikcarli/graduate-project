const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/postgres");

class Photo extends Model {}

Photo.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    path: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  { sequelize, tableName: "photo", timestamps: false }
);

module.exports = Photo;
