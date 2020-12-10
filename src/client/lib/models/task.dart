import 'package:business_travel/models/city.dart';
import 'package:business_travel/models/location.dart';
import 'package:flutter/foundation.dart';

class Task {
  int id;
  int adminId;
  int operatorId;
  Location location;
  City city;
  String name;
  String description;
  bool isOperatorOnTask;
  DateTime startedAt;
  DateTime finishedAt;
  DateTime createdAt;
  DateTime updatedAt;

  Task({
    @required this.id,
    @required this.adminId,
    @required this.operatorId,
    @required this.location,
    @required this.city,
    @required this.name,
    @required this.description,
    @required this.isOperatorOnTask,
    @required this.startedAt,
    @required this.finishedAt,
    @required this.createdAt,
    @required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json["id"],
      adminId: json["adminId"],
      operatorId: json["operatorId"],
      location: Location.fromJson(json["Location"]),
      city: City.fromJson(json["City"]),
      name: json["name"],
      description: json["description"],
      isOperatorOnTask: json["isOperatorOnTask"],
      startedAt: DateTime.tryParse(json["startedAt"]),
      finishedAt: DateTime.tryParse(json["finishedAt"]),
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
      "locationId": location,
      "name": name,
      "city": city.toJson(),
      "description": description,
      "isOperatorOnTask": isOperatorOnTask,
      "startedAt": startedAt.toIso8601String(),
      "finishedAt": finishedAt.toIso8601String(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  Task copy() {
    return Task(
      id: id,
      adminId: adminId,
      operatorId: operatorId,
      location: location.copy(),
      city: city.copy(),
      name: name,
      description: description,
      isOperatorOnTask: isOperatorOnTask,
      startedAt: startedAt,
      finishedAt: finishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
