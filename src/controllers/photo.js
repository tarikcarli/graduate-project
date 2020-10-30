const response = require("../utilities/response");

const { db } = require("../connections/postgres");

const getPhoto = async (req, res, next) => {
  try {
    const { id } = req.query;
    const photo = await db.Photo.findByPk(id);
    const options = {
      data: photo.toJSON(),
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`photo.getPhoto Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

module.exports = {
  getPhoto,
};
