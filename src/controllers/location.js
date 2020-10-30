const response = require("../utilities/response");
const { db } = require("../connections/postgres");

/**
 *To post location
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const postLocation = async (req, res, next) => {
  try {
    const { data } = req.body;
    const location = await db.Location.create(data);
    const options = {
      data: location.toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`location.postLocation Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

/**
 *To get location
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getLocation = async (req, res, next) => {
  try {
    const { id } = req.query;
    const location = await db.Location.findByPk(id);
    const options = {
      data: location.toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`location.getLocation Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

module.exports = {
  postLocation,
  getLocation,
};
