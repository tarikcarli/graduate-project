const { DataTypes, Model } = require("sequelize");
const { sequelize } = require("../connections/postgres");

class Invoice extends Model {}

Invoice.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    businessId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    photoId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    type: {
      type: DataTypes.ENUM,
      allowNull: false,
      values: ["taxi", "other"],
    },
    price: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    invoicedAt: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  },
  {
    sequelize,
    tableName: "invoice",
    timestamps: true,
    updatedAt: false,
  }
);
