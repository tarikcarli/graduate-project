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

    const today = new Date();
    today.setHours(12,0,0,0);
    const yesterday = new Date(today.getTime() - 1000*60*60*24);
    const twoDaysAgo = new Date(today.getTime() - 1000*60*60*24*2);
    const threeDaysAgo = new Date(today.getTime() - 1000*60*60*24*3);
    const fourDaysAgo = new Date(today.getTime() - 1000*60*60*24*4);
    // eslint-disable-next-line no-unused-vars
    const lastWeek = new Date(today.getTime() - 1000*60*60*24*7);
    const nextWeek = new Date(today.getTime() + 1000*60*60*24*7);
    const { locations } = data;
    let j = 1;
    locations.forEach((element,index) => {
      if (j < 70) {
        element.createdAt = (new Date(fourDaysAgo.getTime() + index * 50000)).toISOString();
      } else if (j < 475) {
        element.createdAt = (new Date(threeDaysAgo.getTime() + (index - 70) * 50000)).toISOString();
      } else if (j < 701) {
        element.createdAt = (new Date(twoDaysAgo.getTime() + (index - 475) * 50000)).toISOString();
      } else if (j <= 1398) {
        element.createdAt = (new Date(yesterday.getTime() + (index - 701) * 50000)).toISOString();
      }
      j++;
    });
    await db.Location.bulkCreate(locations);
    const { userLocations } = data; // 4 to 69, 70 to 474, 475 to 700, 701 to 1398
    userLocations.forEach((element,index) => {
      if (element.locationId < 70) {
        element.createdAt = (new Date(fourDaysAgo.getTime() + index * 50000)).toISOString();
      } else if (element.locationId < 475) {
        element.createdAt = (new Date(threeDaysAgo.getTime() + (index - 70) * 50000)).toISOString();
      } else if (element.locationId < 701) {
        element.createdAt = (new Date(twoDaysAgo.getTime() + (index - 475) * 50000)).toISOString();
      } else if (element.locationId <= 1398) {
        element.createdAt = (new Date(yesterday.getTime() + (index - 701) * 50000)).toISOString();
      }
    });
    await db.UserLocation.bulkCreate(userLocations);

    const { tasks } = data;

    today.setHours(0,0,0,0);
    nextWeek.setHours(0,0,0,0);
    tasks[0].startedAt = (new Date(today.getTime() - 1000*60*60*24*4)).toISOString();
    tasks[0].finishedAt = today.toISOString();
    tasks[1].startedAt = today.toISOString();
    tasks[1].finishedAt = nextWeek.toISOString();
    tasks[2].startedAt = nextWeek.toISOString();
    tasks[2].finishedAt = (new Date(nextWeek.getTime() + 1000*60*60*24*3)).toISOString()

    await db.Task.bulkCreate(tasks);

    const { invoices } = data;
    invoices[0].invoicedAt = fourDaysAgo.toISOString();
    invoices[1].invoicedAt = threeDaysAgo.toISOString();
    invoices[2].invoicedAt = twoDaysAgo.toISOString();
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
