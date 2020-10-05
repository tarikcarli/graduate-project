const jwt = require("jsonwebtoken");
const redis = require("../connections/redis");
const { env } = require("../config/env");
const response = require("../utilities/response");

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @returns {undefined}
 */
function auth(req, res, next) {
  const token = req.headers.authorization;
  if (!token) {
    const options = {
      message: "Token is required.",
      status: 400,
    };
    return response(options, req, res, next);
  }

  return jwt.verify(token, env.secret, async (err, decoded) => {
    if (err) {
      console.log(`Auth.jwt.verify Error ${err}`);
      const options = {
        message: "Token is invalid.",
        status: 401,
      };
      return response(options, req, res, next);
    }
    req.reqUserId = Number(decoded.id);
    req.reqUserRole = Number(decoded.role);
    const reply = await redis.get(`token${req.reqUserId.toString()}`);
    if (reply && reply === token) {
      return next();
    }
    const options = {
      message: "Token is invalid.",
      status: 401,
    };
    return response(options, req, res, next);
  });
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @returns {undefined}
 */
function onlyCompany(req, res, next) {
  const { reqUserRole } = req;
  if (reqUserRole === 1) {
    const options = {
      message: "You must be company.",
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
  const { reqUserRole } = req;
  if (reqUserRole === 0) {
    const options = {
      message: "You must be worker.",
      status: 401,
    };
    return response(options, req, res, next);
  }
  return next();
}

module.exports = { auth, onlyCompany, onlyWorker };
