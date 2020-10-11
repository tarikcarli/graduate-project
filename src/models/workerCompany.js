const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class WorkerCompany extends Model {}

WorkerCompany.init(
  {
    workerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      unique: true,
    },
    companyId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  { sequelize, tableName: "worker_company", timestamps: false }
);
