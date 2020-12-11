import 'package:business_travel/models/location.dart';
import 'package:flutter/foundation.dart';

class Task {
  int id;
  int adminId;
  int operatorId;
  Location location;
  int radius;
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
    @required this.radius,
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
      radius: json["radius"],
      name: json["name"],
      description: json["description"],
      isOperatorOnTask: json["isOperatorOnTask"],
      startedAt: DateTime.tryParse(json["startedAt"]).toLocal(),
      finishedAt: DateTime.tryParse(json["finishedAt"]).toLocal(),
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
      "locationId": location,
      "name": name,
      "radius": radius,
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
      radius: radius,
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
