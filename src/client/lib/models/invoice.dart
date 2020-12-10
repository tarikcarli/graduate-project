import 'package:business_travel/models/location.dart';
import 'package:flutter/foundation.dart';

import './photo.dart';

class Invoice {
  int id;
  int adminId;
  int operatorId;
  int taskId;
  Photo photo;
  Location beginLocation;
  Location endLocation;
  double price;
  double estimatePrice;
  double distance;
  double duration;
  bool isValid;
  DateTime createdAt;
  DateTime updatedAt;

  Invoice({
    @required this.id,
    @required this.adminId,
    @required this.operatorId,
    @required this.taskId,
    @required this.beginLocation,
    @required this.endLocation,
    @required this.price,
    @required this.estimatePrice,
    @required this.distance,
    @required this.duration,
    @required this.isValid,
    @required this.createdAt,
    @required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json["id"],
      adminId: json["adminId"],
      operatorId: json["operatorId"],
      taskId: json["taskId"],
      beginLocation: Location.fromJson(json["beginLocation"]),
      endLocation: Location.fromJson(json["endLocation"]),
      price: json["price"],
      estimatePrice: json["estimatePrice"],
      distance: json["distance"],
      duration: json["duration"],
      isValid: json["isValid"],
      createdAt: DateTime.tryParse(json["createdAt"]),
      updatedAt: DateTime.tryParse(
        json["updatedAt"] == null ? json["createdAt"] : json["updatedAt"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "adminId": adminId,
      "operatorId": operatorId,
      "taskId": taskId,
      "beginLocation": beginLocation.toJson(),
      "endLocation": endLocation.toJson(),
      "price": price,
      "estimatePrice": estimatePrice,
      "distance": distance,
      "duration": duration,
      "isValid": isValid,
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
      beginLocation: beginLocation.copy(),
      endLocation: endLocation.copy(),
      price: price,
      estimatePrice: estimatePrice,
      distance: distance,
      duration: duration,
      isValid: isValid,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
