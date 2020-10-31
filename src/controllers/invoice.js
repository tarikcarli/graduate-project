const response = require("../utilities/response");
const image = require("../utilities/image");
const { db } = require("../connections/postgres");

/**
 *To get invoice
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const getInvoice = async (req, res, next) => {
  try {
    const { id, businessId } = req.query;
    if (id) {
      const invoice = await db.Invoice.findByPk(Number.parseInt(id, 10));
      const options = {
        data: invoice,
        status: 200,
      };
      return response(options, req, res, next);
    }
    if (businessId) {
      const invoice = await db.Invoice.findAll({
        where: { businessId: Number.parseInt(businessId, 10) },
      });
      const options = {
        data: invoice,
        status: 200,
      };
      return response(options, req, res, next);
    }
  } catch (err) {
    console.log(`company.getInvoice Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

/**
 *To post invoice
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const postInvoice = async (req, res, next) => {
  try {
    const { type } = req.body.data;
    if (type === "taxi") {
      const { photo, taxi, ...data } = req.body.data;
      const invoice = await db.Invoice.create(data);
      const invoiceLocationBegin = await db.Location.create({
        latitude: taxi.locationBegin.latitude,
        longitude: taxi.locationBegin.longitude,
      });
      const invoiceLocationEnd = await db.Location.create({
        latitude: taxi.locationEnd.latitude,
        longitude: taxi.locationEnd.longitude,
      });
      const invoiceAWSPhotoPromise = image.Base64ImageToS3(
        `invoice${invoice.dataValues.id}`,
        photo
      );
      const invoicePhotoPromise = db.Photo.create({
        path: `invoice${invoice.dataValues.id}`,
      });

      const otherInvoicePromise = db.TaxiInvoice.create({
        distance: taxi.distance,
        priceEstimate: taxi.priceEstimate,
        isValid: taxi.isValid,
        locationBeginId: invoiceLocationBegin.dataValues.id,
        locationEndId: invoiceLocationEnd.dataValues.id,
        invoiceId: invoice.dataValues.id,
      });
      const promiseArray = await Promise.all([
        invoiceAWSPhotoPromise,
        invoicePhotoPromise,
        otherInvoicePromise,
      ]);
      invoice.setPhoto(promiseArray[1]);
      const options = {
        data: {
          ...invoice.dataValues,
          taxi: { ...promiseArray[2].dataValues },
        },
        status: 200,
      };
      return response(options, req, res, next);
    }
    const { photo, other, ...data } = req.body.data;
    const invoice = await db.Invoice.create(data);
    const invoiceLocation = await db.Location.create({
      latitude: other.location.latitude,
      longitude: other.location.longitude,
    });
    const invoiceAWSPhotoPromise = image.Base64ImageToS3(
      `invoice${invoice.dataValues.id}`,
      photo
    );
    const invoicePhotoPromise = db.Photo.create({
      path: `invoice${invoice.dataValues.id}`,
    });

    const otherInvoicePromise = db.OtherInvoice.create({
      locationId: invoiceLocation.dataValues.id,
      invoiceId: invoice.dataValues.id,
    });
    const promiseArray = await Promise.all([
      invoiceAWSPhotoPromise,
      invoicePhotoPromise,
      otherInvoicePromise,
    ]);
    invoice.setPhoto(promiseArray[1]);
    const options = {
      data: {
        ...invoice.dataValues,
        other: { ...promiseArray[2].dataValues },
      },
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.postInvoice Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};
/**
 *To put invoice
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
const putInvoice = async (req, res, next) => {
  try {
    const { id } = req.query;
    const { photo, ...data } = req.body.data;
    if (photo) {
      image.Base64ImageToS3(`invoice${id}`, photo);
    }
    const invoice = await db.Invoice.update(data, {
      where: { id },
      returning: true,
      plain: true,
    });
    const options = {
      data: invoice[1],
      status: 200,
    };
    return response(options, req, res, next);
  } catch (err) {
    console.log(`company.putInvoice Error ${err}`);
  }
  return next(new Error("Unknown Error"));
};

module.exports = {
  getInvoice,
  postInvoice,
  putInvoice,
};
