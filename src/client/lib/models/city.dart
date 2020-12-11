import 'package:flutter/foundation.dart';

class City {
  int id;
  String name;
  double priceInitial;
  double pricePerKm;

  City({
    @required this.id,
    @required this.name,
    @required this.priceInitial,
    @required this.pricePerKm,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json["id"],
      name: json["name"],
      priceInitial: json["priceInitial"].toDouble(),
      pricePerKm: json["pricePerKm"].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "priceInitial": priceInitial,
      "pricePerKm": pricePerKm,
    };
  }

  City copy() {
    return City(
      id: id,
      name: name,
      priceInitial: priceInitial,
      pricePerKm: pricePerKm,
    );
  }
}
