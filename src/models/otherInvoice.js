const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class OtherInvoice extends Model {}

OtherInvoice.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    invoiceId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "invoice_id",
    },
    locationId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "location_id",
    },
  },
  { sequelize, tableName: "invoice_other", timestamps: false }
);
