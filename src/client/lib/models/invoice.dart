import 'package:business_travel/models/city.dart';
import 'package:business_travel/models/location.dart';
import 'package:flutter/foundation.dart';

import './photo.dart';

class Invoice {
  int id;
  int adminId;
  int operatorId;
  int taskId;
  Photo photo;
  City city;
  Location beginLocation;
  Location endLocation;
  int price;
  int estimatePrice;
  int distance;
  int duration;
  bool isValid;
  bool isAccepted;
  DateTime invoicedAt;
  DateTime createdAt;
  DateTime updatedAt;

  Invoice({
    @required this.id,
    @required this.adminId,
    @required this.operatorId,
    @required this.taskId,
    @required this.photo,
    @required this.city,
    @required this.beginLocation,
    @required this.endLocation,
    @required this.price,
    @required this.estimatePrice,
    @required this.distance,
    @required this.duration,
    @required this.isValid,
    @required this.isAccepted,
    @required this.invoicedAt,
    @required this.createdAt,
    @required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json["id"],
      adminId: json["adminId"],
      operatorId: json["operatorId"],
      taskId: json["taskId"],
      city: City.fromJson(json["City"]),
      photo: Photo.fromJson(json["Photo"]),
      beginLocation: Location.fromJson(json["beginLocation"]),
      endLocation: Location.fromJson(json["endLocation"]),
      price: json["price"],
      estimatePrice: json["estimatePrice"],
      distance: json["distance"],
      duration: json["duration"],
      isValid: json["isValid"],
      isAccepted: json["isAccepted"],
      invoicedAt: DateTime.tryParse(json["invoicedAt"]).toLocal(),
      createdAt: DateTime.tryParse(json["createdAt"]).toLocal(),
      updatedAt: DateTime.tryParse(
        json["updatedAt"] == null ? json["createdAt"] : json["updatedAt"],
      ).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "adminId": adminId,
      "operatorId": operatorId,
      "taskId": taskId,
      "photo": photo.toJson(),
      "city": city.toJson(),
      "beginLocation": beginLocation.toJson(),
      "endLocation": endLocation.toJson(),
      "price": price,
      "estimatePrice": estimatePrice,
      "distance": distance,
      "duration": duration,
      "isValid": isValid,
      "isAccepted": isAccepted,
      "invoiceAt": invoicedAt.toIso8601String(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  Invoice copy() {
    return Invoice(
      id: id,
      adminId: adminId,
      operatorId: operatorId,
      taskId: taskId,
      city: city.copy(),
      photo: photo.copy(),
      beginLocation: beginLocation.copy(),
      endLocation: endLocation.copy(),
      price: price,
      estimatePrice: estimatePrice,
      distance: distance,
      duration: duration,
      isValid: isValid,
      isAccepted: isAccepted,
      invoicedAt: invoicedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
