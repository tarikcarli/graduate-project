import 'dart:convert';

import 'package:flutter/foundation.dart';
import "package:http/http.dart" as http;

import './url_creator.dart';
import '../models/photo.dart';

class PhotoService {
  static Future<Photo> getPhoto({int id}) async {
    http.Response response;
    try {
      response = await http.get(
        URL.getPhoto(id: id),
      );
      if (response.statusCode == 200)
        return Photo.fromJson(json.decode(response.body)["data"]);
    } catch (error) {
      print('Error PhotoService.getPhoto: $error');
      throw error;
    }
    throw Exception(
        'Error PhotoService.getPhoto: http status code :${response.statusCode}');
  }

  static Future<Photo> postPhoto({String photo}) async {
    http.Response response;
    try {
      response = await http.post(
        URL.postPhoto(),
        headers: URL.jsonHeader(),
        body: json.encode({
          "data": {"photo": photo}
        }),
      );
      if (response.statusCode == 200) {
        return Photo.fromJson(json.decode(response.body)["data"]);
      }
    } catch (error) {
      print('Error PhotoService.postPhoto: $error');
      throw error;
    }
    throw Exception(
        'Error PhotoService.postPhoto: http status code :${response.statusCode}');
  }

  static Future<Photo> putPhoto(
      {@required int id, @required String photo}) async {
    http.Response response;
    try {
      response = await http.put(
        URL.putPhoto(),
        headers: URL.jsonHeader(),
        body: json.encode({
          "data": {"photo": photo, "id": id}
        }),
      );
      if (response.statusCode == 200)
        return Photo.fromJson(json.decode(response.body)["data"]);
    } catch (error) {
      print('Error PhotoService.putPhoto: $error');
      throw error;
    }
    throw Exception(
        'Error PhotoService.putPhoto: http status code :${response.statusCode}');
  }
}
