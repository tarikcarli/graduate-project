const configs = require("../constants/configs");
/**
 * Disregard middleware function
 * according to the value of the BYPASS_MIDDLEWARE environmental variable.
 * @param {Function} middlewareFunction
 */
function bypassMiddleware(middlewareFunction) {
  if (configs.BYPASS_MIDDLEWARE) {
    return (req, res, next) => next();
  }
  return middlewareFunction;
}

module.exports = bypassMiddleware;
