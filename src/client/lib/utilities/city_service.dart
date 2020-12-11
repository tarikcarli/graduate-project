import 'dart:convert';

import 'package:business_travel/models/city.dart';
import 'package:business_travel/utilities/url_creator.dart';
import "package:http/http.dart" as http;

class CityService {
  static List<City> cities = [];

  static Future<void> getCities({token}) async {
    if (cities.length != 81) {
      http.Response response;
      try {
        response = await http.get(
          URL.getCity(),
          headers: URL.jsonHeader(token: token),
        );
        if (response.statusCode == 200) {
          json.decode(response.body)["data"].forEach((e) {
            cities.add(City.fromJson(e));
          });
          return;
        }
      } catch (error) {
        print("Error getCities: $error");
        throw error;
      }
      throw Exception('Bilinmeyen bir hata oluştu.\n' +
          'Http hata kodu: ${response.statusCode}');
    } else {
      return Future(() => null);
    }
  }
}
