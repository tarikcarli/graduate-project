const { Op } = require("sequelize").Op;
const response = require("../utilities/response");
const { sign } = require("../utilities/jwt");
const redis = require("../connections/redis");
const { db } = require("../connections/postgres");

/**
 *To create a company user
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const register = async (req, res, next) => {
  try {
    const { password, ...data } = req.body.data;
    data.password = await db.User.hashPassword(password);
    data.role = "other";
    const user = await db.User.create(data);
    const options = {
      data: user,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error user.register ${err}`);
    if (err && err.errors && err.errors[0].type === "unique violation") {
      const options = {
        message: "The user have this email have already registered.",
        status: 409,
      };
      return response(options, req, res, next);
    }
    const options = {
      message: err.toString(),
      status: 500,
    };
    return response(options, req, res, next);
  }
};

/**
 *To get operators belongs to Admin
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getWorkers = async (req, res, next) => {
  try {
    const adminId = Number.parseInt(req.query.adminId, 10);
    const users = await db.UserUser.findAll({
      where: { adminId },
      include: {
        model: db.User,
        as: "operator",
        attributes: {
          exclude: "photoId",
        },
        include: {
          model: db.Photo,
        },
      },
    });
    const options = { data: users.map((e) => e.operator), status: 200 };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error user.getWorkers: ${err}`);
    const options = { message: err.toString(), status: 500 };
    return response(options, req, res, next);
  }
};

/**
 *To get Admin belongs to operator
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getAdmin = async (req, res, next) => {
  try {
    const operatorId = Number.parseInt(req.query.operatorId, 10);
    const user = await db.UserUser.findOne({
      where: { operatorId },
      include: {
        model: db.User,
        as: "admin",
        attributes: {
          exclude: ["photoId"],
        },
        include: {
          model: db.Photo,
        },
      },
    });
    const options = { data: user.admin, status: 200 };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error user.getWorkers: ${err}`);
    const options = { message: err.toString(), status: 500 };
    return response(options, req, res, next);
  }
};

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body.data;
    const user = await db.User.findOne({
      where: {
        email,
      },
      attributes: {
        exclude: ["photoId"],
      },
      include: {
        model: db.Photo,
      },
    });
    if (!user) {
      const options = {
        message: "No user associated with this email.",
        status: 400,
      };
      return response(options, req, res, next);
    }
    const result = await user.verifyPassword(password);
    if (!result) {
      const options = {
        message: "Password mismatch.",
        status: 401,
      };
      return response(options, req, res, next);
    }
    const token = await sign({ id: user.id, role: user.role });
    user.dataValues.token = token;
    await redis.set(`token${user.id}`, token);
    const options = {
      data: user,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`user.login Error ${err}`);
  }
  return next(new Error("Someting went wrong"));
};

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const logout = async (req, res, next) => {
  try {
    const { id } = req.query;
    await redis.del(`token${id}`);
    const options = {
      data: {},
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`user.logout Error ${err}`);
  }
  return next(new Error("Someting went wrong"));
};

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const update = async (req, res, next) => {
  try {
    const { id, role, operatorIds } = req.body.data;
    if (role) {
      const user = await db.User.update(
        { role },
        { where: { id }, planning: true, returning: true }
      );
      if (role === "other") {
        await db.UserUser.destroy({
          where: { [Op.or]: [{ operatorId: id }, { adminId: id }] },
        });
      }
      if (role === "operator") {
        await db.UserUser.destroy({
          where: { adminId: id },
        });
      }
      if (role === "admin") {
        await db.UserUser.destroy({
          where: { operatorId: id },
        });
      }
      const options = { data: user[1][0], status: 200 };
      return response(options, req, res, next);
    }
    if (operatorIds) {
      await db.UserUser.destroy({ where: { adminId: id } });
      const userUser = operatorIds.map((e) => {
        return { adminId: id, operatorId: e };
      });
      const userUserResult = await db.UserUser.bulkCreate(userUser);
      const options = { data: userUserResult, status: 200 };
      return response(options, req, res, next);
    }
    return undefined;
  } catch (err) {
    console.log(`Error user.update ${err}`);
    const options = {
      message: err.toString(),
      status: 500,
    };
    return response(options, req, res, next);
  }
};

module.exports = {
  register,
  update,
  login,
  logout,
  getWorkers,
  getAdmin,
};
