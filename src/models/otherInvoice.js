const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/postgres");

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
    },
    locationId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  { sequelize, tableName: "invoice_other", timestamps: false }
);
