const env = {
  dbUrl: process.env.DB_URL,
  redisUrl: process.env.REDIS_URL,
  rabbitmqUrl: process.env.RABBITMQ_URL,
  secret: process.env.SECRET,
  port: Number.parseInt(process.env.PORT, 10),
  test: process.env.TEST === "true",
  logging: process.env.LOGGING === "true",
  AWSAccessKeyId: "",
  AWSSecretKey: "",
  S3_BUCKET_NAME: "",
};
console.log(env);

exports.env = env;
