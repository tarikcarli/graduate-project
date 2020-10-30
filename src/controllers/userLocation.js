const { Op } = require("sequelize");
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

    const location = await db.UserLocation.create(data);
    const options = {
      data: location.toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`userLocation.postLocation Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

/**
 *To post locations
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const postLocations = async (req, res, next) => {
  try {
    const { data } = req.body.data;
    const locations = await db.UserLocation.bulkCreate(data);
    // data.startedAt = new Date(data.startedAt);
    // data.finishedAt = new Date(data.finishedAt);
    const options = {
      data: locations.toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`post.locations Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};
/**
 *To get history location
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getHistoryLocation = async (req, res, next) => {
  try {
    const userId = Number.parseInt(req.query.id, 10);
    const { startDate, finishDate } = req.query;
    const locations = await db.UserLocation.findAll({
      where: {
        [Op.and]: [
          { userId },
          {
            createdAt: {
              [Op.between]: [startDate, finishDate],
            },
          },
        ],
      },
    });
    console.log(locations);
    const options = {
      data: locations,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`userLocation.getHistoryLocation Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

/**
 *To get current location
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getCurrentLocation = async (req, res, next) => {
  try {
    const userId = req.query.id;
    const location = await db.UserLocation.findOne({
      where: {
        userId,
      },
      order: [["createdAt", "DESC"]],
    });
    const options = {
      data: location.toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`userLocation.getCurrentLocation Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

module.exports = {
  postLocation,
  postLocations,
  getHistoryLocation,
  getCurrentLocation,
};
