const env = require("../config/env");
const { DataTypes } = require("sequelize");
const { sequelize } = require("../connection/db");

const Log = sequelize.define(
  "Log",
  {
    id: {
      field: "id",
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      field: "user_id",
      type: DataTypes.INTEGER,
    },
    ip: {
      field: "ip",
      type: DataTypes.STRING,
    },
    method: {
      field: "method",
      type: DataTypes.STRING,
    },
    body: {
      field: "body",
      type: DataTypes.TEXT,
    },
    headers: {
      field: "headers",
      type: DataTypes.TEXT,
    },
    message: {
      field: "message",
      type: DataTypes.TEXT,
    },
    status: {
      field: "status",
      type: DataTypes.INTEGER,
    },
    url: {
      field: "url",
      type: DataTypes.STRING,
    },
    createdAt: {
      field: "created_at",
      type: DataTypes.DATE,
    },
  },
  {
    tableName: "t_dg_log",
    schema: env.SCHEMA,
    freezeTableName: true,
    timestamps: true,
    updatedAt: false,
  }
);

module.exports = Log;
