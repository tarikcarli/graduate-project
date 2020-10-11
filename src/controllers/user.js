const response = require("../utilities/response");
const { sign } = require("../utilities/jwt");
const redis = require("../connections/redis");
const image = require("../utilities/image");
/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const login = async (req, res, next) => {
  try {
    const { db } = req;
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
    console.log(result);
    if (!result) {
      const options = {
        message: "Password mismatch.",
        status: 401,
      };
      return response(options, req, res, next);
    }
    const token = await sign({ id: user.id, role: user.role });
    let loginResponse;
    if (user.role === "company") {
      loginResponse = await db.User.findByPk(user.id, {
        attributes: {
          exclude: ["photoId"],
        },
        include: [
          {
            model: db.Photo,
          },
          {
            model: db.WorkerCompany,
            as: "Worker",
            attributes: {
              exclude: ["id"],
            },
            include: {
              model: db.User,
              as: "CompanyWorker",
              attributes: {
                exclude: ["password", "photoId"],
              },
              include: {
                model: db.Photo,
              },
            },
          },
        ],
      });
    } else {
      loginResponse = await db.User.findByPk(user.id, {
        attributes: {
          exclude: ["photoId"],
        },
        include: [
          {
            model: db.Photo,
          },
          {
            model: db.WorkerCompany,
            as: "Company",
            attributes: {
              exclude: ["id"],
            },
            include: {
              model: db.User,
              as: "WorkerCompany",
              attributes: {
                exclude: ["password", "photoId"],
              },
              include: {
                model: db.Photo,
              },
            },
          },
        ],
      });
    }
    loginResponse.dataValues.token = token;
    await redis.set(`token${user.id}`, token);
    const options = {
      data: loginResponse.toJSON(),
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
    const { db, userId } = req;
    const { email, password, photo } = req.body.data;
    const data = {};
    if (email) {
      data.email = email;
    }
    if (password) {
      data.password = await db.User.hashPassword(password);
    }
    if (photo) {
      await image.Base64ImageToS3(`user${userId}`, photo);
    }
    console.log(data);
    console.log(userId);
    const user = await db.User.update(data, { where: { id: userId } });
    if (user[0] === 1) {
      const options = {
        data: {},
        status: 200,
      };
      return response(options, req, res, next);
    }
  } catch (err) {
    console.log(`user.update Error ${err}`);
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
