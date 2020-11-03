const response = require("../utilities/response");
const { db } = require("../connections/postgres");

/**
 *To get business
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getBusiness = async (req, res, next) => {
  try {
    const { id, companyId, workerId } = req.query;
    if (id) {
      const business = await db.Business.findByPk(Number.parseInt(id, 10));
      const options = {
        data: business,
        status: 200,
      };
      return response(options, req, res, next);
    }
    if (companyId) {
      const business = await db.Business.findAll({
        where: { companyId: Number.parseInt(companyId, 10) },
      });
      const options = {
        data: business,
        status: 200,
      };
      return response(options, req, res, next);
    }
    if (workerId) {
      const business = await db.Business.findAll({
        where: { workerId: Number.parseInt(workerId, 10) },
      });
      const options = {
        data: business,
        status: 200,
      };
      return response(options, req, res, next);
    }
  } catch (err) {
    console.log(`company.getBusiness Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

/**
 *To post business
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const postBusiness = async (req, res, next) => {
  try {
    const { data } = req.body;
    const business = await db.Business.create(data);
    const options = {
      data: business,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.postBusiness Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

/**
 *To put business
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const putBusiness = async (req, res, next) => {
  try {
    const { id } = req.query;
    const { data } = req.body;
    const business = await db.Business.update(data, {
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
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.putBusiness Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

module.exports = {
  getBusiness,
  postBusiness,
  putBusiness,
};
