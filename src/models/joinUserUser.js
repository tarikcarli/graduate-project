const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/postgres");

class UserUser extends Model {}

UserUser.init(
  {
    adminId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
    },
    operatorId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
    },
  },
  {
    sequelize,
    tableName: "user_user",
    timestamps: false,
  }
);
