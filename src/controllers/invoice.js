const response = require("../utilities/response");
const { db } = require("../connections/postgres");

/**
 *To get invoice
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getInvoice = async (req, res, next) => {
  try {
    const { id, businessId } = req.query;
    if (id) {
      const invoice = await db.Invoice.findByPk(Number.parseInt(id, 10));
      const options = {
        data: invoice,
        status: 200,
      };
      return response(options, req, res, next);
    }
    if (businessId) {
      const invoice = await db.Invoice.findAll({
        where: { businessId: Number.parseInt(businessId, 10) },
      });
      const options = {
        data: invoice,
        status: 200,
      };
      return response(options, req, res, next);
    }
  } catch (err) {
    console.log(`company.getInvoice Error ${err}`);
  }
  return next(new Error("Unknown Error"));
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
    const { type } = req.body.data;
    if (type === "taxi") {
      const { taxi, ...data } = req.body.data;
      const invoice = await db.Invoice.create(data);

      const taxiInvoice = await db.TaxiInvoice.create({
        ...taxi,
        invoiceId: invoice.dataValues.id,
      });

      const options = {
        data: {
          ...invoice.dataValues,
          taxi: { ...taxiInvoice.dataValues },
        },
        status: 200,
      };
      return response(options, req, res, next);
    }
    const { other, ...data } = req.body.data;
    const invoice = await db.Invoice.create(data);

    const otherInvoice = await db.OtherInvoice.create({
      ...other,
      invoiceId: invoice.dataValues.id,
    });
    const options = {
      data: {
        ...invoice.dataValues,
        other: { ...otherInvoice.dataValues },
      },
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.postInvoice Error ${err}`);
  }
  return next(new Error("Unknown Error"));
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
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.putInvoice Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

module.exports = {
  getInvoice,
  postInvoice,
  putInvoice,
};
