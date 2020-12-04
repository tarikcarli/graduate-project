const cities = require("../constants/city.json");
const { db } = require("../connections/postgres");

async function populateCity() {
  // eslint-disable-next-line no-restricted-syntax
  for (const city of cities) {
    // eslint-disable-next-line no-await-in-loop
    await db.City.create({
      name: city.name,
      priceInitial: 5,
      pricePerKm: 5,
    });
  }
}
module.exports = populateCity;
