const fs = require("fs");
const path = require("path");
const env = require("../config/env");
const AWS = require("aws-sdk");

AWS.config.update({
  accessKeyId: env.AWSAccessKeyId,
  secretAccessKey: env.AWSSecretKey,
});

const s3 = new AWS.S3();

/**
 * Write base64 encoded image data to
 * the jpeg file to relative path public/images
 * according to project root
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
  s3.upload(params, function (error, data) {
    if (error) console.log(`writeBase64Image.s3.upload Error ${error}`);
    if (data) console.log(`writeBase64Image.s3.upload Success ${data}`);
  });
};

/**
 * Read jpeg image file from relative path
 * public/images according to project root.
 *
 * @param {String} imagePath
 *  * @param {import("express").Response} res

 * @return {any}
 */
// const readImageAsBase64 = (res, imagePath) => {
//   const filePath = path.join("temp", imagePath);
//   const params = {
//     Bucket: process.env.AWS_BUCKET,
//     Key: imagePath,
//   };
//   s3.getObject(params, (err, data) => {
//     if (err) console.error(err);
//     // @ts-ignore
//     fs.writeFile(filePath, data.Body, {}, () => {
//       res.download(filePath, function (error) {
//         if (error) console.log(res.headersSent);
//         else {
//           fs.unlink(filePath, function (error) {
//             if (err) console.log(`fs.unlink Error ${error}`);
//             else console.log(`fs.unlink Success`);
//           });
//         }
//       });
//     });
//   });
// };

module.exports = { writeBase64Image /*, readImageAsBase64*/ };
