const response = require("../utilities/response");
const image = require("../utilities/image");
const { db } = require("../connections/db");
/**
 *To create a company user
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const register = async (req, res, next) => {
  try {
    // const { db } = req;
    const { photo, password, ...data } = req.body.data;
    data.role = "company";
    data.companyId = null;
    data.password = await db.User.hashPassword(password);
    const user = await db.User.create(data);
    image.Base64ImageToS3(`user${user.id}`, photo);
    await user.createPhoto({ path: `user${user.id}` });
    const options = {
      data: user.toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.register Error ${err}`);
    if (err && err.errors && err.errors[0].type === "unique violation") {
      const options = {
        message: "The user have this email have already registered.",
        status: 409,
      };
      return response(options, req, res, next);
    }
  }
  return next(new Error("Something went wrong"));
};
/**
 *To get workers belongs to Company
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getWorkers = async (req, res, next) => {
  try {
    // const {  db } = req;
    const { userId } = req;
    const users = await db.User.findAll({
      where: { companyId: userId },
      attributes: {
        exclude: ["photoId", "password"],
      },
      include: {
        model: db.Photo,
      },
    });
    const options = { data: users, status: 200 };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.getWorkers Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};
module.exports = { register, getWorkers };
