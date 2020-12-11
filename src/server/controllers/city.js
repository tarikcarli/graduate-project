const response = require("../utilities/response");
const { db } = require("../connections/postgres");
/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getCities = async (req, res, next) => {
  try {
    const cities = await db.City.findAll();
    const options = {
      data: cities,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error getCities: ${err}`);
    return next(err);
  }
};

module.exports = {
  getCities,
};
