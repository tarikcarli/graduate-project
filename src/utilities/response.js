const { sequelize } = require("../connections/postgres");
const configs = require("../constants/configs");

/**
 * Log http request into the database.
 *
 * @param {{message:string,status:number}} options options object
 * @param {import("express").Request} req Request object with header
 */
async function log(options, req) {
  let { reqUserId } = req;
  if (reqUserId) reqUserId = 0;
  const db = req.db || sequelize.models;
  await db.Log.create({
    ip: req.connection.remoteAddress,
    userId: reqUserId,
    method: req.method,
    body: JSON.stringify(req.body),
    headers: JSON.stringify(req.headers),
    url: req.originalUrl,
    message: options.message,
    status: options.status,
  });
}

/**
 * Send http response to request that coming by parameter.
 *
 * @param {Object} options Request object with header,
 * @param {import("express").Request} req Request object with header
 * @param {import("express").Response} res Response object with header
 * @param {import("express").NextFunction} next EXpress next function with header
 * @return {undefined}
 */
function response(options, req, res, next) {
  if (!options) {
    next(Error("Options parameter required."));
    return;
  }
  if (!options.status) {
    next(Error("Options.status parameter required."));
    return;
  }
  if (
    (options.message && options.data) ||
    (!options.message && !options.data)
  ) {
    next(Error("Either options.data or options.message parameter required."));
    return;
  }

  const responseData = {
    data: options.data,
    message: options.message,
  };
  if (!configs.LOG_ONLY_ERROR || options.status >= 400) log(options, req);

  res.status(options.status).json(responseData);
}

module.exports = response;
