const config = {
  POSTGRES_URL: process.env.POSTGRES_URL,
  REDIS_URL: process.env.REDIS_URL,
  PRODUCTION: process.env.PRODUCTION === "true",
  DEVELOPMENT: process.env.DEVELOPMENT === "true",
  RECREATE_DB: process.env.RECREATE_DB === "true",
  LOAD_DUMMY_DATA: process.env.LOAD_DUMMY_DATA === "true",
  LOG_ONLY_ERROR: process.env.LOG_ONLY_ERROR === "true",
  BYPASS_MIDDLEWARE: process.env.BYPASS_MIDDLEWARE === "true",
  JWT_SECRET: process.env.JWT_SECRET,
  PORT: process.env.PORT,
  APP_DOMAIN: process.env.APP_DOMAIN, 
};
console.log(config);

module.exports = config;
