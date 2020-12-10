import 'package:business_travel/models/photo.dart';

class User {
  int id;
  Photo photo;
  String role;
  String name;
  String email;
  String password;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    this.id,
    this.photo,
    this.role,
    this.name,
    this.email,
    this.password,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      photo: json['Photo'] == null ? null : Photo.fromJson(json['Photo']),
      role: json['role'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "photo": photo.toJson(),
      "role": role,
      "name": name,
      "email": email,
      "password": password,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  User copy() {
    return User(
      id: id,
      photo: photo.copy(),
      role: role,
      name: name,
      email: email,
      password: password,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
