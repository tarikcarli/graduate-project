const { Op } = require("sequelize");
const response = require("../utilities/response");
const { sign } = require("../utilities/jwt");
const redis = require("../connections/redis");
const wsTypes = require("../constants/ws_types");
const { db } = require("../connections/postgres");

/**
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function getOperatorIds(req, res, next) {
  const { adminId } = req.query;
  try {
    const operators = await db.UserUser.findAll({
      attributes: ["operatorId"],
      where: { adminId },
    });
    const options = {
      data: operators.map((element) => element.operatorId),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(` Error user.getOperatorIds: ${err}`);
    return next(err);
  }
}

/**
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function getOperators(req, res, next) {
  const { adminId } = req.query;
  try {
    const operators = await db.UserUser.findAll({
      attributes: ["operatorId"],
      where: { adminId },
      include: {
        model: db.User,
        as: "operator",
        include: {
          model: db.Photo,
        },
      },
    });
    const options = {
      data: operators.map((element) => element.operator),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`User.getOperators Error ${err}`);
    return next(err);
  }
}
/**
 *To get Admin belongs to operator
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getAdmin = async (req, res, next) => {
  try {
    const { operatorId } = req.query;
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
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function getAllUser(req, res, next) {
  try {
    const operators = await db.User.findAll({ include: db.Photo });
    const options = {
      data: operators,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (error) {
    console.log(`User.getAllUsers Error ${error}`);
  }
  return next(new Error("Unknown Error"));
}

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
    if (user && user.getDataValue("role") === "other") {
      const options = {
        message: "User has other role cannot login",
        status: 403,
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
    await redis.set(`token-${user.id}`, token);
    const options = {
      data: user,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`user.login Error ${err}`);
    return next(err);
  }
};

/**
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function assignOperator(req, res, next) {
  const { data } = req.body;
  try {
    const userUser = await db.UserUser.create(data);
    const options = {
      data: userUser,
      status: 200,
    };
    redis.publish(data.adminId, wsTypes.OPERATOR_ADD, data);
    redis.publish(data.operatorId, wsTypes.ADMIN_ADD, data);
    return response(options, req, res, next);
  } catch (error) {
    console.log(`User.assignOperator Error ${error}`);
    if (error && error.errors && error.errors[0].type === "unique violation") {
      const options = {
        message: "The operator has already admin.",
        status: 409,
      };
      return response(options, req, res, next);
    }
    return next(error);
  }
}

/**
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function unassignOperator(req, res, next) {
  const { adminId, operatorId } = req.body.data;
  try {
    const userUser = await db.UserUser.destroy({
      where: { adminId, operatorId },
    });
    const options = {
      data: userUser,
      status: 200,
    };
    redis.publish(adminId, wsTypes.OPERATOR_REMOVE, { adminId, operatorId });
    redis.publish(operatorId, wsTypes.ADMIN_REMOVE, { adminId, operatorId });
    return response(options, req, res, next);
  } catch (error) {
    console.log(`User.unassignOperator Error ${error}`);
    return next(error);
  }
}

/**
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function update(req, res, next) {
  const { id, ...data } = req.body.data;
  try {
    const user = await db.User.update(data, {
      where: {
        id,
      },
      plaining: true,
      returning: true,
    });
    const options = {
      data: user,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (error) {
    console.log(`User.update Error ${error}`);
    if (error && error.errors && error.errors[0].type === "unique violation") {
      const options = {
        message: "The user have this email have already registered.",
        status: 409,
      };
      return response(options, req, res, next);
    }
    return next(error);
  }
}

/**
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function updateRole(req, res, next) {
  const { id, role } = req.body.data;
  try {
    if (role === "admin")
      await db.UserUser.destroy({ where: { operatorId: id } });
    if (role === "operator")
      await db.UserUser.destroy({ where: { adminId: id } });
    if (role === "other")
      await db.UserUser.destroy({
        where: { [Op.or]: [{ operatorId: id }, { adminId: id }] },
      });
    const user = await db.User.update(
      { role },
      { where: { id }, returning: true, plain: true }
    );
    const options = {
      data: user[1],
      status: 200,
    };
    return response(options, req, res, next);
  } catch (error) {
    console.log(`User.updateRole Error ${error}`);
    return next(error);
  }
}

/**
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function updatePassword(req, res, next) {
  console.log(req.body);
  const { id, password } = req.body.data;
  try {
    const user = await db.User.findByPk(id);

    const hash = await db.User.hashPassword(password);
    console.log(hash);
    user.setDataValue("password", hash);

    const updatedUser = await user.save();
    const options = {
      data: updatedUser,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (error) {
    console.log(`Error updatePassword: ${error}`);
    return next(error);
  }
}

/**
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function deleteOperator(req, res, next) {
  const { id } = req.query;
  try {
    await db.UserUser.destroy({
      where: { [Op.or]: [{ operatorId: id }, { adminId: id }] },
    });
    const user = await db.User.findByPk(id);
    if (!user) {
      const options = {
        message: "Not Found",
        status: 404,
      };
      return response(options, req, res, next);
    }
    await user.destroy();
    const options = {
      data: { id: user.id },
      status: 200,
    };
    return response(options, req, res, next);
  } catch (error) {
    console.log(`User.deleteOperator Error ${error}`);
    return next(error);
  }
}

/**
 * api end point handler function.
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @return {Promise<undefined>}
 */
async function getMe(req, res, next) {
  const { id } = req.query;
  try {
    const user = await db.User.findByPk(id, {
      attributes: {
        exclude: ["password"],
      },
      include: {
        model: db.Photo,
      },
    });
    const options = {
      data: user,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (error) {
    console.log(`Error user.getMe: ${error}`);
  }
  return next(Error(""));
}

module.exports = {
  register,
  login,
  assignOperator,
  unassignOperator,
  update,
  updateRole,
  updatePassword,
  logout,
  getOperators,
  getOperatorIds,
  getAdmin,
  getAllUser,
  getMe,
  deleteOperator,
};
