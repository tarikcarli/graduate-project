import 'package:flutter/foundation.dart';

class Location {
  int id;
  int operatorId;
  double latitude;
  double longitude;
  DateTime createdAt;

  Location({
    @required this.latitude,
    @required this.longitude,
    this.createdAt,
    this.id,
    this.operatorId,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    Location location = Location(
      latitude: json['latitude'],
      longitude: json["longitude"],
    );
    if (json["createdAt"] != null) {
      location.createdAt = DateTime.tryParse(json["createdAt"]);
    }
    if (json["id"] != null) {
      location.id = json["id"];
    }
    if (json["operatorId"] != null) {
      location.operatorId = json["operatorId"];
    }
    return location;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "latitude": latitude,
      "longitude": longitude,
    };
    if (createdAt != null) {
      json["createdAt"] = createdAt.toIso8601String();
    }
    if (id != null) {
      json["id"] = id;
    }
    if (operatorId != null) {
      json["operatorId"] = operatorId;
    }
    return json;
  }

  Location copy() {
    return Location(
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      id: id,
      operatorId: operatorId,
    );
  }
}
