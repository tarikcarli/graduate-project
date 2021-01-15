import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:background_locator/location_dto.dart';
import 'package:business_travel/providers/location.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';

  int _count = -1;
  String token;
  int adminId;
  int operatorId;
  Future<void> init(Map<dynamic, dynamic> params) async {
    try {
      if (params.containsKey('countInit')) {
        if (params.containsKey('countInit')) {
          _count = int.parse(params['countInit']);
        }
        if (params.containsKey('token')) {
          token = params['token'];
        }
        if (params.containsKey('adminId')) {
          adminId = int.parse(params['adminId']);
        }
        if (params.containsKey('operatorId')) {
          operatorId = int.parse(params['operatorId']);
        }
        final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
        send?.send(null);
      }
    } catch (error) {
      print("Error isolate init: $error");
    } finally {
      print(
          "Isolates is running with count: $_count token: $token adminId: $adminId operatorId: $operatorId");
    }
  }

  Future<void> dispose() async {
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    // print("*****************************************************");
    // print("getPosition $_count Location: ${locationDto.toJson()}");
    // print("timeStamp: ${locationDto.time}");
    // print(
    //     "DateTime: ${DateTime.fromMillisecondsSinceEpoch(locationDto.time.toInt()).toString()}");
    final createdAt =
        DateTime.fromMillisecondsSinceEpoch(locationDto.time.toInt());
    try {
      await sendLocationWithCheck(
        adminId: adminId,
        operatorId: operatorId,
        latitude: locationDto.latitude,
        longitude: locationDto.longitude,
        createdAt: createdAt,
        token: token,
      );
      final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
      send?.send(locationDto);
      _count++;
    } catch (error) {
      print("************************");
      print("Error in callback, sendLocationWithCheck: $error");
    }
  }

  static Future<void> getPosition({
    int count,
    String token,
    int adminId,
    int operatorId,
    LocationDto data,
  }) async {}

  static double dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static String formatDateLog(DateTime date) {
    return date.hour.toString() +
        ":" +
        date.minute.toString() +
        ":" +
        date.second.toString();
  }

  static String formatLog(LocationDto locationDto) {
    return dp(locationDto.latitude, 4).toString() +
        " " +
        dp(locationDto.longitude, 4).toString();
  }
}
