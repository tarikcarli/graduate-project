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
    const user = await db.User.create(data);
    const options = {
      data: user,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.register Error ${err}`);
    if (err && err.errors && err.errors[0].type === "unique violation") {
      const options = {
        message: "The user have this email have already registered.",
        status: 409,
      };
      return response(options, req, res, next);
    }
  }
  return next(new Error("Something went wrong"));
};

/**
 *To get workers belongs to Company
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getWorkers = async (req, res, next) => {
  try {
    const companyId = Number.parseInt(req.query.companyId, 10);
    const users = await db.User.findAll({
      where: { companyId },
      attributes: {
        exclude: ["photoId", "password"],
      },
      include: {
        model: db.Photo,
      },
    });
    const options = { data: users, status: 200 };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.getWorkers Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

/**
 *To get workers belongs to Company
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getAdmin = async (req, res, next) => {
  try {
    const companyId = Number.parseInt(req.query.companyId, 10);
    const users = await db.User.findByPk(companyId, {
      attributes: {
        exclude: ["photoId", "password"],
      },
      include: {
        model: db.Photo,
      },
    });
    const options = { data: users, status: 200 };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.getWorkers Error ${err}`);
  }
  return next(new Error("Unknown Error"));
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
    await user.getPhoto();
    user.dataValues.token = token;
    await redis.set(`token${user.id}`, token);
    const options = {
      data: user.toJSON(),
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
    const { id, ...data } = req.body.data;
    if (data.password) {
      data.password = await db.User.hashPassword(data.password);
    }
    const user = await db.User.update(data, {
      where: { id },
      returning: true,
      plain: true,
    });
    user[1].dataValues.Photo = await user[1].getPhoto();
    const options = {
      data: user[1].toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`user.update Error ${err}`);
    if (err && err.errors && err.errors[0].type === "unique violation") {
      const options = {
        message: "The user have this email have already registered.",
        status: 409,
      };
      return response(options, req, res, next);
    }
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
const tokenStatus = (req, res, next) => {
  const options = {
    data: {},
    status: 200,
  };
  return response(options, req, res, next);
};

module.exports = {
  register,
  update,
  login,
  logout,
  tokenStatus,
  getWorkers,
  getAdmin,
};
