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
        include: [db.Location],
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
        include: [db.Location],
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
        include: [db.Location],
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
    const location = await task.getLocation();
    task.setDataValue("Location", location);
    const options = {
      data: task,
      status: 200,
    };
    publish(data.operatorId, wsTypes.TASK_ADD_NOTIFICATION, {});
    publish(data.operatorId, wsTypes.TASK_ADD, task.dataValues);
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error postTask: ${err}`);
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
    const dbTask = await db.Task.findByPk(id);
    const task = await db.Task.update(data, {
      where: {
        id,
      },
      returning: true,
      plain: true,
    });
    const location = await task[1].getLocation();
    task[1].setDataValue("Location", location);
    const options = {
      data: task[1],
      status: 200,
    };
    if (dbTask.dataValues.isOperatorOnTask !== data.isOperatorOnTask) {
      if (dbTask.dataValues.isOperatorOnTask)
        publish(data.adminId, wsTypes.OPERATOR_ENTER_NOTIFICATION, {});
      else publish(data.adminId, wsTypes.OPERATOR_LEAVE_NOTIFICATION, {});
    } else {
      publish(data.operatorId, wsTypes.TASK_UPDATE, task[1].dataValues);
    }
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error putTask: Error ${err}`);
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
const deleteTask = async (req, res, next) => {
  try {
    const { id } = req.query;
    const task = await db.Task.findByPk(id);
    await db.Task.destroy({
      where: {
        id,
      },
    });
    const options = {
      data: {},
      status: 200,
    };
    publish(task.dataValues.operatorId, wsTypes.TASK_DELETE, task.dataValues);
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error deleteTask: ${err}`);
    return next(err);
  }
};
module.exports = {
  getTask,
  postTask,
  putTask,
  deleteTask,
};
