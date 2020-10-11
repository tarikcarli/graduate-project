const response = require("../utilities/response");
const image = require("../utilities/image");
/**
 *To create a company user
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const register = async (req, res, next) => {
  try {
    const { db } = req;
    const { photo, password, ...data } = req.body.data;
    data.role = "company";
    data.password = await db.User.hashPassword(password);
    const user = await db.User.create(data);
    await image.Base64ImageToS3(`user${user.id}`, photo);
    const dbPhoto = await db.Photo.create({ path: `user${user.id}` });
    user.photoId = dbPhoto.id;
    await user.save();
    const options = {
      data: {},
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

module.exports = { register };
