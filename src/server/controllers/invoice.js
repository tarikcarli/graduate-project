const response = require("../utilities/response");
const { db } = require("../connections/postgres");
const wsTypes = require("../constants/ws_types");
const { publish } = require("../connections/redis");
/**
 *To get invoice
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getInvoice = async (req, res, next) => {
  try {
    const { id, taskId, operatorId, adminId } = req.query;
    if (id) {
      const invoice = await db.Invoice.findByPk(Number.parseInt(id, 10), {
        include: ["beginLocation", "endLocation", db.City, db.Photo],
      });
      const options = {
        data: invoice,
        status: 200,
      };
      return response(options, req, res, next);
    }
    if (taskId) {
      const invoice = await db.Invoice.findAll({
        where: { taskId },
        include: ["beginLocation", "endLocation", db.City, db.Photo],
      });
      const options = {
        data: invoice,
        status: 200,
      };
      return response(options, req, res, next);
    }
    if (operatorId) {
      const invoice = await db.Invoice.findAll({
        where: { operatorId },
        include: ["beginLocation", "endLocation", db.City, db.Photo],
      });
      const options = {
        data: invoice,
        status: 200,
      };
      return response(options, req, res, next);
    }
    // AdminId default
    const invoice = await db.Invoice.findAll({
      where: { adminId },
      include: ["beginLocation", "endLocation", db.City, db.Photo],
    });
    const options = {
      data: invoice,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error getInvoice: ${err}`);
    throw err;
  }
};

/**
 *To post invoice
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const postInvoice = async (req, res, next) => {
  try {
    const { data } = req.body;
    const invoice = await db.Invoice.create(data);
    const options = {
      data: invoice,
      status: 200,
    };
    publish(data.operatorId, wsTypes.INVOICE_ADD, options.data);
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error company.postInvoice: ${err}`);
    return next(err);
  }
};
/**
 *To put invoice
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const putInvoice = async (req, res, next) => {
  try {
    const { id } = req.query;
    const { data } = req.body;
    const invoice = await db.Invoice.update(data, {
      where: { id },
      returning: true,
      plain: true,
    });
    const options = {
      data: invoice[1],
      status: 200,
    };
    publish(data.adminId, wsTypes.INVOICE_UPDATE, options.data);
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.putInvoice Error ${err}`);
    return next(err);
  }
};

module.exports = {
  getInvoice,
  postInvoice,
  putInvoice,
};
