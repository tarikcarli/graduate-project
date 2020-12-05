const { DataTypes, Model } = require("sequelize");
const bcrypt = require("bcrypt");
const { sequelize } = require("../connections/postgres");

class User extends Model {
  /**
   * To compare plain text password to hash password value.
   * @param {String} password plain text password
   * @memberof User
   */
  async verifyPassword(password) {
    return new Promise((resolve, _reject) => {
      return bcrypt.compare(password, this.password, (err, result) => {
        return resolve(result);
      });
    });
  }

  /**
   * To compare plain text password to hash password value.
   * @param {String} password plain text password
   * @memberof User
   */
  static async hashPassword(password) {
    return new Promise((resolve, reject) => {
      bcrypt.genSalt(10, (err, salt) => {
        if (err) {
          return reject(err);
        }
        return bcrypt.hash(password, salt, (err, hash) => {
          if (err) {
            return reject(err);
          }
          return resolve(hash);
        });
      });
    });
  }
}

User.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    photoId: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    role: {
      type: DataTypes.ENUM,
      allowNull: false,
      values: ["system", "admin", "operator", "other"],
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    sequelize,
    tableName: "user",
    timestamps: true,
  }
);
