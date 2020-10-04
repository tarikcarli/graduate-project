const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

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
      field: "location_begin",
    },
    locationEnd: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "location_end",
    },
    priceEstimate: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "price_estimate",
    },
    distance: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  { sequelize, tableName: "invoice_taxi", timestamps: false }
);
