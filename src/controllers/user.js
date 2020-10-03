/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const login = (req, res, next) => {
  const { data } = req.body;
};

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const changePassword = (req, res, next) => {
  const { data } = req.body;
};

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const changePhoto = (req, res, next) => {
  const { data } = req.body;
};

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const changeInfo = (req, res, next) => {
  const { data } = req.body;
};

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const tokenStatus = (req, res, next) => {
  const { data } = req.body;
};

/**
 *
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const serverStatus = (req, res, next) => {
  const { data } = req.body;
};

exports.login = login;
exports.changePassword = changePassword;
exports.changePhoto = changePhoto;
exports.changeInfo = changeInfo;
exports.tokenStatus = tokenStatus;
exports.serverStatus = serverStatus;
