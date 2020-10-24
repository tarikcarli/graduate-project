const response = require("../utilities/response");
const { db } = require("../connections/postgres");

/**
 *To post business
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const postBusiness = async (req, res, next) => {
  try {
    const { location, ...data } = req.body.data;
    const businessLocation = await db.Location.create({
      latitude: location.latitude,
      longitude: location.longitude,
    });
    data.locationId = businessLocation.dataValues.id;
    data.startedAt = new Date(data.startedAt);
    data.finishedAt = new Date(data.finishedAt);
    const business = await db.Business.create(data);
    const options = {
      data: business.toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.postBusiness Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

/**
 *To get business
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getBusiness = async (req, res, next) => {
  try {
    const { location, ...data } = req.body.data;
    const businessLocation = await db.Location.create({
      latitude: location.latitude,
      longitude: location.longitude,
    });
    data.locationId = businessLocation.dataValues.id;
    data.startedAt = new Date(data.startedAt);
    data.finishedAt = new Date(data.finishedAt);
    const business = await db.Business.create(data);
    const options = {
      data: business.toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.postBusiness Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

module.exports = {
  postBusiness,
  getBusiness,
};
