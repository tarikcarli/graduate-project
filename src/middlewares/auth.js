const redis = require("../connections/redis");
const jwt = require("jsonwebtoken");
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
  const token = req.headers["authorization"];
  if (!token) {
    const options = {
      message: "Token is required.",
      status: 400,
    };
    return response(options, req, res, next);
  }

  jwt.verify(token, env.secret, async (err, decoded) => {
    if (err) {
      console.log(`Auth.jwt.verify Error ${err}`);
      const options = {
        message: "Token is invalid.",
        status: 401,
      };
      return response(options, req, res, next);
    }
    // @ts-ignore
    req.reqUserId = Number(decoded.id);
    // @ts-ignore
    req.reqUserRole = Number(decoded.role);
    // @ts-ignore
    const reply = await redis.get(`token${req.reqUserId.toString()}`);
    if (reply && reply === token) {
      return next();
    } else {
      const options = {
        message: "Token is invalid.",
        status: 401,
      };
      return response(options, req, res, next);
    }
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
  // @ts-ignore
  const { reqUserRole } = req;
  if (reqUserRole === 1) {
    const options = {
      message: "You must be company.",
      status: 401,
    };
    return response(options, req, res, next);
  }
  next();
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @returns {undefined} undefined
 */
function onlyWorker(req, res, next) {
  // @ts-ignore
  const { reqUserRole } = req;
  if (reqUserRole === 0) {
    const options = {
      message: "You must be worker.",
      status: 401,
    };
    return response(options, req, res, next);
  }
  next();
}

module.exports = { auth, onlyCompany, onlyWorker };
