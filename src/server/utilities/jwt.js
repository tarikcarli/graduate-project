const jwt = require("jsonwebtoken");
const configs = require("../constants/configs");
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
 * @param {userId:String, userRole:String} data
 */
function sign(data) {
  return new Promise((resolve, reject) => {
    return jwt.sign(data, configs.JWT_SECRET, {}, (err, token) => {
      if (err) return reject(err);
      return resolve(token);
    });
  });
}

module.exports = { verify, sign };
