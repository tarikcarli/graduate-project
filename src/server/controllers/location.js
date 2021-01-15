const { Op } = require("sequelize");
const response = require("../utilities/response");
const { db } = require("../connections/postgres");
const wsTypes = require("../constants/ws_types");
const { publish } = require("../connections/redis");

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
    if (!location) {
      throw new Error("Not Found");
    }
    const options = {
      data: location,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error location.getLocation: ${err}`);
    const options = {
      message: err.toString(),
      status: 500,
    };
    return response(options, req, res, next);
  }
};

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
      data: location,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`location.postLocation Error ${err}`);
    const options = {
      message: err.toString(),
      status: 500,
    };
    return response(options, req, res, next);
  }
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
    const operatorId = Number.parseInt(req.query.operatorId, 10);
    const { startDate, finishDate } = req.query;
    const locations = await db.UserLocation.findAll({
      where: {
        [Op.and]: [
          { operatorId },
          {
            createdAt: {
              [Op.between]: [startDate, finishDate],
            },
          },
        ],
      },
      include: {
        model: db.Location,
      },
    });
    const result = {
      operatorId,
      locations: locations.map((e) => {
        return e.Location;
      }),
    };
    const options = {
      data: result,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error location.getHistoryLocation: ${err}`);
    const options = {
      message: err.toString(),
      status: 500,
    };
    return response(options, req, res, next);
  }
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
    const { operatorId } = req.query;
    const location = await db.UserLocation.findOne({
      where: {
        operatorId,
      },
      order: [["id", "DESC"]],
      include: {
        model: db.Location,
      },
    });
    location.dataValues.Location.dataValues.operatorId = Number(operatorId);
    const options = {
      data: location.dataValues.Location,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error location.getCurrentLocation: ${err}`);
    return next(err);
  }
};

/**
 *To post location
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const postUserLocation = async (req, res, next) => {
  try {
    const { adminId, operatorId, location: data } = req.body.data;
    const location = await db.Location.create(data);
    await db.UserLocation.create({
      operatorId,
      locationId: location.id,
      createdAt: data.createdAt,
    });
    location.dataValues.operatorId = operatorId;
    const options = {
      data: location,
      status: 200,
    };
    publish(adminId, wsTypes.OPERATOR_LOCATION_ADD, options.data);
    return response(options, req, res, next);
  } catch (err) {
    console.log(`userLocation.postLocation Error ${err}`);
    return next(err);
  }
};

/**
 *To post locations
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const postUserLocations = async (req, res, next) => {
  try {
    const { operatorId, locations } = req.body.data;
    const results = await db.Location.bulkCreate(locations);
    const userLocationsInput = results.map((e) => {
      return { operatorId, locationId: e.dataValues.id, createdAt:e.dataValues.createdAt };
    });
    await db.UserLocation.bulkCreate(userLocationsInput);
    const options = {
      data: { operatorId, locations: results },
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error location.postUserLocations: ${err}`);
    const options = {
      message: err.toString(),
      status: 500,
    };
    return response(options, req, res, next);
  }
};

module.exports = {
  postUserLocation,
  postUserLocations,
  getHistoryLocation,
  getCurrentLocation,
  postLocation,
  getLocation,
};
