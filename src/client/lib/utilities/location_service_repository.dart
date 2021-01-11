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
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
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

  Future<void> dispose() async {
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    // print('$_count location in dart: ${locationDto.toString()}');

    await getPosition(
        count: _count,
        data: locationDto,
        token: token,
        adminId: adminId,
        operatorId: operatorId);
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto);
    _count++;
  }

  static Future<void> getPosition({
    int count,
    String token,
    int adminId,
    int operatorId,
    LocationDto data,
  }) async {
    // print("****************************");
    // print("getPosition Location: ${data.toJson()}");
    try {
      await sendLocationWithCheck(
        adminId: adminId,
        operatorId: operatorId,
        latitude: data.latitude,
        longitude: data.longitude,
        token: token,
      );
    } catch (error) {
      print("************************");
      print("Error in getPosition sendLocationWithCheck: $error");
    }
  }

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
