const fs = require("fs");
const path = require("path");
const AWS = require("aws-sdk");
const configs = require("../constants/configs");

AWS.config.update({
  accessKeyId: configs.aws.accessKey,
  secretAccessKey: configs.aws.secretKey,
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
  if (configs.dev) {
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
    Bucket: configs.aws.s3Bucket,
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
