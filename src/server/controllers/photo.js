/* eslint-disable no-use-before-define */
const fs = require("fs");
const path = require("path");
const { uuid } = require("uuidv4");
const response = require("../utilities/response");
const { db } = require("../connections/postgres");

const assetsRootPath = path.join(__dirname, "../../..", "public", "images");

const getPhoto = async (req, res, next) => {
  try {
    const { id } = req.query;
    const photo = await db.Photo.findByPk(id);
    const options = {
      data: photo,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error photo.getPhoto: ${err}`);
    return next(err);
  }
};

const postPhoto = async (req, res, next) => {
  try {
    const photoData = req.body.data.photo;
    const photoPath = uuid();
    await writePhotoToFileSystem(photoData, photoPath);
    const photo = await db.Photo.create({ path: photoPath });
    const options = {
      data: photo,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error photo.postPhoto: ${err}`);
    const options = {
      message: err.toString(),
      status: 500,
    };
    return response(options, req, res, next);
  }
};

const putPhoto = async (req, res, next) => {
  try {
    const { id } = req.body.data;
    const photoData = req.body.data.photo;
    const photoPath = uuid();
    const photo = await db.Photo.findByPk(Number.parseInt(id, 10));
    await deletePhotoToFileSystem(photo.dataValues.path);
    await writePhotoToFileSystem(photoData, photoPath);
    photo.path = photoPath;
    await photo.save();
    const options = {
      data: photo,
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`Error photo.putPhoto: ${err}`);
    const options = {
      message: err.toString(),
      status: 500,
    };
    return response(options, req, res, next);
  }
};

module.exports = {
  getPhoto,
  postPhoto,
  putPhoto,
};

/**
 *
 *
 * @param {String} data
 * @param {String} path
 * @returns {Promise<void>}
 */
function writePhotoToFileSystem(photoData, photoPath) {
  return new Promise((resolve, reject) => {
    fs.writeFile(
      path.join(assetsRootPath, `${photoPath}.jpg`),
      photoData,
      "base64",
      (err) => {
        if (err) {
          console.log(`fs.writePhoto Error ${err}`);
          return reject(err);
        }
        return resolve();
      }
    );
  });
}

/**
 *
 *
 * @param {String} path
 * @returns {Promise<void>}
 */
function deletePhotoToFileSystem(photoPath) {
  return new Promise((resolve, reject) => {
    fs.unlink(path.join(assetsRootPath, `${photoPath}.jpg`), (err) => {
      if (err) {
        console.log(`fs.deletePhoto Error ${err}`);
        return reject(err);
      }
      return resolve();
    });
  });
}
