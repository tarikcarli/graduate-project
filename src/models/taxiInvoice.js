const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/postgres");

class TaxiInvoice extends Model {}

TaxiInvoice.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    invoiceId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    locationBegin: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    locationEnd: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    priceEstimate: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    distance: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  { sequelize, tableName: "invoice_taxi", timestamps: false }
);
