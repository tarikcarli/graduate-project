const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class Business extends Model {}

Business.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    companyId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "company_id",
    },
    workerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "worker_id",
    },
    locationId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "location_id",
    },
    cityId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "city_id",
    },
    radius: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    description: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    budget: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    expense: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    startedAt: {
      type: DataTypes.DATE,
      allowNull: false,
      field: "started_at",
    },
    finishedAt: {
      type: DataTypes.DATE,
      allowNull: false,
      field: "finished_at",
    },
  },
  {
    sequelize,
    tableName: "business",
    timestamps: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
  }
);
