const fs = require("fs");
const path = require("path");
const AWS = require("aws-sdk");
const { env } = require("../config/env");

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
const Base64ImageToS3 = (imagePath, data) => {
  if (env.test) {
    const binaryData = Buffer.from(data);
    return new Promise((resolve, reject) => {
      fs.writeFile(
        path.join(__dirname, "../../public/images", `${imagePath}.jpeg`),
        binaryData,
        (err) => {
          if (err) return reject(err);
          return resolve();
        }
      );
    });
  }
  const params = {
    Bucket: env.S3_BUCKET_NAME,
    Body: Buffer.from(data, "base64"),
    Key: imagePath,
  };
  return new Promise((resolve, reject) => {
    s3.upload(params, (err, data) => {
      if (err) {
        console.log(`writeBase64Image.s3.upload Error ${err}`);
        reject(err);
      }
      if (data) {
        console.log(`writeBase64Image.s3.upload Success ${data}`);
        resolve(data);
      }
    });
  });
};

module.exports = { Base64ImageToS3 };
