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
    const created = await db.Invoice.create(data);
    const invoice = await db.Invoice.findByPk(created.id, {
      include: ["beginLocation", "endLocation", db.City, db.Photo],
    });
    const options = {
      data: invoice,
      status: 200,
    };
    publish(data.adminId, wsTypes.INVOICE_ADD, options.data);
    publish(data.adminId, wsTypes.INVOICE_ADD_NOTIFICATION, {});

    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error postInvoice: ${err}`);
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
    const invoice = await db.Invoice.findByPk(id, {
      include: ["beginLocation", "endLocation", db.City, db.Photo],
    });
    if (invoice.getDataValue("isAccepted") !== data.isAccepted) {
      publish(data.operatorId, wsTypes.INVOICE_UPDATE, invoice);
      publish(data.operatorId, wsTypes.INVOICE_UPDATE_NOTIFICATION, {});
    } else publish(data.adminId, wsTypes.INVOICE_UPDATE, invoice);

    await db.Invoice.update(data, {
      where: { id },
    });
    console.log(invoice.dataValues);
    console.log(data);
    const invoice2 = await invoice.reload();
    const options = {
      data: invoice2,
      status: 200,
    };
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
