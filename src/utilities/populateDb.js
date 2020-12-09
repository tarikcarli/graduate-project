/* eslint-disable no-restricted-syntax */
/* eslint-disable no-await-in-loop */
/* eslint-disable no-use-before-define */
const fs = require("fs");
const path = require("path");
const { uuid } = require("uuidv4");
const data = require("../constants/db_data.json");

const { db } = require("../connections/postgres");

async function populateDb() {
  for (const photo of data.photos) {
    const photoPath = uuid();
    await writePhotoToFileSystem(photo, photoPath);
    await db.Photo.create({ path: photoPath });
  }

  const { cities } = data;
  await db.City.bulkCreate(cities);

  const { users } = data;
  for (const user of users) {
    user.password = await db.User.hashPassword(user.password);
  }
  await db.User.bulkCreate(users);

  const { userusers } = data;
  await db.UserUser.bulkCreate(userusers);
}

const assetsRootPath = path.join(__dirname, "../..", "public", "images");

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
module.exports = populateDb;
