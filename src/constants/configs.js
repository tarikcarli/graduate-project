const config = {
  postgres: {
    url: process.env.POSTGRES_URL,
  },
  redis: {
    url: process.env.REDIS_URL,
  },
  rabbitmq: {
    url: process.env.RABBITMQ_URL,
  },
  aws: {
    accessKey: process.env.AWS_ACCESS_KEY,
    secretKey: process.env.AWS_SECRET_KEY,
    s3Bucket: process.env.AWS_S3_BUCKET,
  },
  jwt: {
    secret: process.env.JWT_SECRET,
  },
  port: Number.parseInt(process.env.PORT, 10),
  test: process.env.TEST === "true",
  dev: process.env.DEV === "true",
  logOnlyError: process.env.LOG_ONLY_ERROR === "true",
};
console.log(config);

module.exports = config;
