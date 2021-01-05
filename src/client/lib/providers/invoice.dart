import 'dart:convert';

import 'package:business_travel/models/invoice.dart';
import 'package:business_travel/utilities/photo_service.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InvoiceProvider with ChangeNotifier {
  List<Invoice> invoices = [];

  Future<void> fetchAndSetInvoices(
      {String token, int operatorId, int adminId}) async {
    http.Response response;
    try {
      response = await http.get(
        URL.getInvoice(operatorId: operatorId, adminId: adminId),
        headers: URL.jsonHeader(
          token: token,
        ),
      );
      if (response.statusCode == 200) {
        invoices = [];
        json.decode(response.body)["data"].forEach((e) {
          invoices.add(Invoice.fromJson(e));
        });
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error fetchAndSetInvoices: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> addInvoice({
    @required int adminId,
    @required int operatorId,
    @required int taskId,
    @required String photo,
    @required int beginLocationId,
    @required int endLocationId,
    @required int cityId,
    @required int price,
    @required int estimatePrice,
    @required int distance,
    @required int duration,
    @required bool isValid,
    @required bool isAccepted,
    @required DateTime invoicedAt,
    @required String token,
  }) async {
    http.Response response;
    try {
      final responsePhoto = await PhotoService.postPhoto(photo: photo);
      response = await http.post(
        URL.postInvoice(),
        headers: URL.jsonHeader(
          token: token,
        ),
        body: json.encode(
          {
            "data": {
              "adminId": adminId,
              "operatorId": operatorId,
              "taskId": taskId,
              "photoId": responsePhoto.id,
              "beginLocationId": beginLocationId,
              "endLocationId": endLocationId,
              "cityId": cityId,
              "price": price,
              "estimatePrice": estimatePrice,
              "distance": distance,
              "duration": duration,
              "isValid": isValid,
              "isAccepted": isAccepted,
              "invoicedAt": invoicedAt.toUtc().toIso8601String(),
            },
          },
        ),
      );
      if (response.statusCode == 200) {
        Invoice invoice = Invoice.fromJson(
          json.decode(
            response.body,
          )["data"],
        );
        invoices.insert(0, invoice);
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error addInvoice: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> putInvoice({
    @required int id,
    @required int adminId,
    @required int operatorId,
    @required int taskId,
    @required String photo,
    @required int beginLocationId,
    @required int endLocationId,
    @required int cityId,
    @required int price,
    @required int estimatePrice,
    @required int distance,
    @required int duration,
    @required bool isValid,
    @required bool isAccepted,
    @required DateTime invoicedAt,
    @required String token,
  }) async {
    http.Response response;
    try {
      if (photo != null) {
        final responsePhoto = await PhotoService.postPhoto(photo: photo);
        response = await http.put(
          URL.putInvoice(id: id),
          headers: URL.jsonHeader(
            token: token,
          ),
          body: json.encode(
            {
              "data": {
                "adminId": adminId,
                "operatorId": operatorId,
                "taskId": taskId,
                "photoId": responsePhoto.id,
                "beginLocationId": beginLocationId,
                "endLocationId": endLocationId,
                "cityId": cityId,
                "price": price,
                "estimatePrice": estimatePrice,
                "distance": distance,
                "duration": duration,
                "isValid": isValid,
                "isAccepted": isAccepted,
                "invoicedAt": invoicedAt.toUtc().toIso8601String(),
              },
            },
          ),
        );
      } else {
        response = await http.put(
          URL.putInvoice(id: id),
          headers: URL.jsonHeader(
            token: token,
          ),
          body: json.encode(
            {
              "data": {
                "adminId": adminId,
                "operatorId": operatorId,
                "taskId": taskId,
                "beginLocationId": beginLocationId,
                "endLocationId": endLocationId,
                "cityId": cityId,
                "price": price,
                "estimatePrice": estimatePrice,
                "distance": distance,
                "duration": duration,
                "isValid": isValid,
                "isAccepted": isAccepted,
                "invoicedAt": invoicedAt.toUtc().toIso8601String(),
              },
            },
          ),
        );
      }
      if (response.statusCode == 200) {
        Invoice invoice = Invoice.fromJson(
          json.decode(
            response.body,
          )["data"],
        );
        invoices =
            invoices.map((e) => e.id == invoice.id ? invoice : e).toList();
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error updateInvoice: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> sendInvoiceMail({String token, int id}) async {
    http.Response response;
    try {
      response = await http.post(
        URL.sendInvoiceMail(id: id),
        headers: URL.jsonHeader(
          token: token,
        ),
      );
      if (response.statusCode == 200) {
        return;
      }
    } catch (error) {
      print("Error sendInvoiceMail: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  List<Invoice> filterInvoice(int taskId) {
    if (taskId == 0) return invoices;
    return invoices.where((element) => element.taskId == taskId).toList();
  }
}
