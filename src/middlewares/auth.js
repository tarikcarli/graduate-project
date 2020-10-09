const jwt = require("jsonwebtoken");
const redis = require("../connections/redis");
const { sequelize } = require("../connections/db");
const { env } = require("../config/env");
const response = require("../utilities/response");

/**
 *
 * @param {String} token
 * @param {String} secret
 */
function verify(token, secret) {
  return new Promise((resolve, reject) => {
    jwt.verify(token, secret, async (err, decoded) => {
      if (err) {
        return reject(err);
      }
      return resolve(decoded);
    });
  });
}

/**
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 * @returns {undefined}
 */
async function auth(req, res, next) {
  try {
    const token = req.headers.authorization;
    if (!token) {
      const options = {
        message: "Token is required.",
        status: 400,
      };
      return response(options, req, res, next);
    }
    const decoded = await verify(token, env.secret);
    req.userId = Number(decoded.id);
    req.userRole = Number(decoded.role);
    req.db = sequelize.models;
    const reply = await redis.get(`token${req.reqUserId.toString()}`);
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

module.exports = { auth, onlyCompany, onlyWorker };
