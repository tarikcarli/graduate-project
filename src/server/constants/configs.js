const config = {
  POSTGRES_URL: process.env.POSTGRES_URL,
  REDIS_URL: process.env.REDIS_URL,
  PRODUCTION: process.env.PRODUCTION === "true",
  DEVELOPMENT: process.env.DEVELOPMENT === "true",
  TEST: process.env.TEST === "true",
  LOG_ONLY_ERROR: process.env.LOG_ONLY_ERROR === "true",
  BYPASS_MIDDLEWARE: process.env.BYPASS_MIDDLEWARE === "true",
  JWT_SECRET: process.env.JWT_SECRET,
  PORT: process.env.PORT,
};
console.log(config);

module.exports = config;