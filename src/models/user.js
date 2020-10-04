const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class User extends Model {}

User.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    photoId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "photo_id",
    },
    role: {
      tpye: DataTypes.INTEGER,
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    phoneNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      field: "phone_number",
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    sequelize,
    tableName: "user",
    timestamps: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);
