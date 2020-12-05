/* eslint-disable no-await-in-loop */
/* eslint-disable no-restricted-syntax */
/* eslint-disable no-use-before-define */
const cities = require("../constants/city.json");
const users = require("../constants/user.json");

const { db } = require("../connections/postgres");

async function populateDb() {
  await populateCity();
  await populateUser();
}
async function populateCity() {
  for (const city of cities) {
    await db.City.create({
      name: city.name,
      priceInitial: 5,
      pricePerKm: 5,
    });
  }
}

async function populateUser() {
  for (const user of users) {
    await db.User.create({
      photoId: user.photoId,
      role: user.role,
      name: user.name,
      email: user.email,
      password: await db.User.hashPassword(user.password),
    });
  }
}

module.exports = populateDb;
