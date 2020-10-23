const response = require("../utilities/response");
const { sign } = require("../utilities/jwt");
const redis = require("../connections/redis");
const image = require("../utilities/image");
const { db } = require("../connections/db");

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const login = async (req, res, next) => {
  try {
    // const { db } = req;
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
    const { userId } = req;
    await redis.del(`token${userId}`);
    const options = {
      data: { userId },
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
    // const { db } = req;
    const { userId } = req;
    const { email, password, photo } = req.body.data;
    const data = {};
    if (email) {
      data.email = email;
    }
    if (password) {
      data.password = await db.User.hashPassword(password);
    }
    if (photo) {
      image.Base64ImageToS3(`user${userId}`, photo);
    }
    const user = await db.User.update(data, {
      where: { id: userId },
      returning: true,
      plain: true,
    });
    if (user[1]) {
      const options = {
        data: user[1].toJSON(),
        status: 200,
      };
      return response(options, req, res, next);
    }
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

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const serverStatus = (req, res, next) => {
  const options = {
    data: {},
    status: 200,
  };
  return response(options, req, res, next);
};

exports.login = login;
exports.logout = logout;
exports.update = update;
exports.tokenStatus = tokenStatus;
exports.serverStatus = serverStatus;
