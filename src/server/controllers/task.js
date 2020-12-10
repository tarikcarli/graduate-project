const response = require("../utilities/response");
const { publish } = require("../connections/redis");
const wsTypes = require("../constants/ws_types");
const { db } = require("../connections/postgres");

/**
 *To get business
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getTask = async (req, res, next) => {
  try {
    const { id, adminId, operatorId } = req.query;
    if (id) {
      const task = await db.Task.findByPk(Number.parseInt(id, 10), {
        include: [db.Location, db.City],
      });
      const options = {
        data: task,
        status: 200,
      };
      return response(options, req, res, next);
    }
    if (operatorId) {
      const business = await db.Task.findAll({
        where: {
          operatorId: Number.parseInt(operatorId, 10),
        },
        include: [db.Location, db.City],
      });
      const options = {
        data: business,
        status: 200,
      };
      return response(options, req, res, next);
    }
    if (adminId) {
      const business = await db.Task.findAll({
        where: {
          adminId: Number.parseInt(adminId, 10),
        },
        include: [db.Location, db.City],
      });
      const options = {
        data: business,
        status: 200,
      };
      return response(options, req, res, next);
    }
    return undefined;
  } catch (err) {
    console.log(`Error task.getTask: ${err}`);
    return next(err);
  }
};

/**
 *To post business
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const postTask = async (req, res, next) => {
  try {
    const { data } = req.body;
    const task = await db.Task.create(data);
    const options = {
      data: task,
      status: 200,
    };
    publish(data.operatorId, wsTypes.BUSINESS_ADD, task.dataValues);
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error task.postTask: ${err}`);
    return next(err);
  }
};

/**
 *To put business
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const putTask = async (req, res, next) => {
  try {
    const { id } = req.query;
    const { data } = req.body;
    const business = await db.Task.update(data, {
      where: {
        id,
      },
      returning: true,
      plain: true,
    });
    const options = {
      data: business[1],
      status: 200,
    };
    publish(data.adminId, wsTypes.BUSINESS_UPDATE, business.dataValues);
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.putBusiness Error ${err}`);
    return next(err);
  }
};

module.exports = {
  getBusiness: getTask,
  postBusiness: postTask,
  putBusiness: putTask,
};
