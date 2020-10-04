const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/db");

class Invoice extends Model {}

Invoice.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
    },
    businessId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "business_id",
    },
    photoId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: "photo_id",
    },
    type: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    price: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    invoicedAt: {
      type: DataTypes.DATE,
      allowNull: false,
      field: "invoiced_at",
    },
  },
  {
    sequelize,
    tableName: "invoice",
    timestamps: true,
    updatedAt: false,
    createdAt: "created_at",
  }
);
