import 'package:flutter/foundation.dart';

class Photo {
  int id;
  String path;

  Photo({
    @required this.id,
    @required this.path,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      path: json["path"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "path": path,
    };
  }

  Photo copy() {
    return Photo(
      id: id,
      path: path,
    );
  }
}
