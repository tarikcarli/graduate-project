const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class WorkerCompany extends Model {}

WorkerCompany.init(
  {
    workerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      unique: true,
      field: "worker_id",
    },
    companyId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "company_id",
    },
  },
  { sequelize }
);
