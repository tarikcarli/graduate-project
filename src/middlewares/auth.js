const redis = require("../connections/redis");
const configs = require("../constants/configs");
const bypassMiddleware = require("../utilities/middlewareWrapper");
const response = require("../utilities/response");
const { verify } = require("../utilities/jwt");

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @returns {undefined}
 */
async function auth(req, res, next) {
  try {
    const baererToken = req.headers.authorization;
    const token = baererToken.split(" ")[1];
    if (!token) {
      const options = {
        message: "Token is required.",
        status: 400,
      };
      return response(options, req, res, next);
    }
    const decoded = await verify(token, configs.JWT_SECRET);
    req.userId = Number(decoded.id);
    req.userRole = Number(decoded.role);
    const reply = await redis.get(`token${req.userId.toString()}`);
    if (!reply || reply !== token) {
      throw new Error("Token isn't stored.");
    }
  } catch (err) {
    console.log(`Auth Error ${err}`);
    const options = {
      message: "Token is invalid.",
      status: 401,
    };
    return response(options, req, res, next);
  }
  return next();
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @returns {undefined}
 */
function onlyCompany(req, res, next) {
  const { userRole } = req;
  if (userRole === 1) {
    const options = {
      message: "You must have company role.",
      status: 401,
    };
    return response(options, req, res, next);
  }
  return next();
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @returns {undefined}
 */
function onlyWorker(req, res, next) {
  const { userRole } = req;
  if (userRole === 0) {
    const options = {
      message: "You must have worker role.",
      status: 401,
    };
    return response(options, req, res, next);
  }
  return next();
}

module.exports = {
  auth: bypassMiddleware(auth),
  onlyCompany: bypassMiddleware(onlyCompany),
  onlyWorker: bypassMiddleware(onlyWorker),
};
