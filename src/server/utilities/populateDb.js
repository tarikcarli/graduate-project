/* eslint-disable no-plusplus */
/* eslint-disable new-cap */
/* eslint-disable no-param-reassign */
/* eslint-disable no-restricted-syntax */
/* eslint-disable no-await-in-loop */
/* eslint-disable no-use-before-define */
const fs = require("fs");
const path = require("path");
const { uuid } = require("uuidv4");
const data = require("../constants/db_data.json");

const { db } = require("../connections/postgres");

async function populateDb() {
  try {
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
    const date = new Date();
    date.setDate(1);
    date.setHours(5, 0, 0, 0);
    const { locations } = data;
    let j = 0;
    locations.forEach((element) => {
      if (j < 70) {
        element.createdAt = date.toISOString();
      } else if (j < 475) {
        date.setDate(2);
        element.createdAt = date.toISOString();
      } else if (j < 701) {
        date.setDate(3);
        element.createdAt = date.toISOString();
      } else if (j < 1398) {
        date.setDate(4);
        element.createdAt = date.toISOString();
      }
      j++;
    });
    await db.Location.bulkCreate(locations);
    date.setDate(1);
    const { userLocations } = data; // 4 to 69, 70 to 474, 475 to 700, 701 to 1398
    userLocations.forEach((element) => {
      if (element.locationId < 70) {
        element.createdAt = date.toISOString();
      } else if (element.locationId < 475) {
        date.setDate(2);
        element.createdAt = date.toISOString();
      } else if (element.locationId < 701) {
        date.setDate(3);
        element.createdAt = date.toISOString();
      } else if (element.locationId < 1398) {
        date.setDate(4);
        element.createdAt = date.toISOString();
      }
    });
    await db.UserLocation.bulkCreate(userLocations);

    const { tasks } = data;
    let i = 1;
    date.setHours(0, 0, 0, 0);

    tasks.forEach((element) => {
      date.setDate(i);
      element.startedAt = date.toISOString();
      i += 5;
      date.setDate(i);
      element.finishedAt = date.toISOString();
      i += 5;
    });
    await db.Task.bulkCreate(tasks);

    const { invoices } = data;
    i = 1;
    date.setHours(5, 0, 0, 0);
    invoices.forEach((element) => {
      date.setDate(i++);
      element.invoicedAt = date.toISOString();
    });
    await db.Invoice.bulkCreate(invoices);
  } catch (err) {
    console.log(`Error populateDb: ${err}`);
  }
}

const assetsRootPath = path.join(__dirname, "../../..", "public", "images");

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
