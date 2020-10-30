const response = require("../utilities/response");

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const serverStatus = (req, res, next) => {
  const options = {
    data: {},
    status: 200,
  };
  return response(options, req, res, next);
};

module.exports = {
  serverStatus,
};
