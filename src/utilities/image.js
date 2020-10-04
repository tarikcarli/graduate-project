const AWS = require("aws-sdk");
const env = require("../config/env");

AWS.config.update({
  accessKeyId: env.AWSAccessKeyId,
  secretAccessKey: env.AWSSecretKey,
});

const s3 = new AWS.S3();

/**
 * Write base64 encoded image data to
 * the jpeg file to AWS S3 BUDGET.
 *
 * @param {String} imagePath
 * @param {String} data
 * @return {void}
 */
const writeBase64Image = (imagePath, data) => {
  const params = {
    Bucket: env.S3_BUCKET_NAME,
    Body: Buffer.from(data, "base64"),
    Key: imagePath,
  };
  return s3.upload(params, (error, data) => {
    if (error) console.log(`writeBase64Image.s3.upload Error ${error}`);
    if (data) console.log(`writeBase64Image.s3.upload Success ${data}`);
  });
};

module.exports = { writeBase64Image };
