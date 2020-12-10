import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:business_travel/models/location.dart';
import 'package:business_travel/utilities/location_functions.dart';
import 'package:business_travel/utilities/location_service_repository.dart';
import 'package:business_travel/utilities/offline_location_storage.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import "package:http/http.dart" as http;
import 'package:latlong/latlong.dart';

class LocationProvider with ChangeNotifier {
  Location currentLocation;
  List<Location> currentOperatorLocations = [];
  List<Location> historyLocationBig = []; //10m
  List<Location> historyLocationMedium = []; //50m
  List<Location> historyLocationSmall = []; //500m
  List<Location> historyLocationBorder = []; //first and last
  bool isAllowedBackgroundTracking = false;

  void settingsBackgroundTracking() async {
    ReceivePort port = ReceivePort();
    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }
    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);
    port.listen(
      (dynamic data) async {
        print(data);
      },
    );
    print('Initializing...');
    await BackgroundLocator.initialize();
    print('Initialization done');
    final _isRunning = await BackgroundLocator.isServiceRunning();
    print('Running $_isRunning');
  }

  void allowBackgroundTracking() async {
    isAllowedBackgroundTracking = true;
    if (await LocationFunctions.checkLocationPermission()) {
      LocationFunctions.startLocator();
      print("yes");
    } else {
      print(
          "---> In Location Provider allowBackgroundTracking => Occurred Error !!");
    }
    LocationFunctions.startLocator();
    notifyListeners();
  }

  void deniedBackgroundTracking() {
    isAllowedBackgroundTracking = false;
    LocationFunctions.stopLocator();
    notifyListeners();
  }

  void toogleBackgroundTracking() {
    if (isAllowedBackgroundTracking) {
      deniedBackgroundTracking();
    } else {
      allowBackgroundTracking();
    }
    notifyListeners();
  }

  Future<void> fetchAndSetLocationHistory({
    @required int operatorId,
    @required String token,
    @required DateTime startDate,
    @required DateTime finishDate,
  }) async {
    http.Response response;
    try {
      response = await http.get(
        URL.getHistoryLocation(
          operatorId: operatorId,
          startDate: startDate,
          finishDate: finishDate,
        ),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        historyLocationBig = [];
        json.decode(response.body)["data"].forEach((e) {
          historyLocationBig.add(Location.fromJson(e));
        });
        historyLocationBig.forEach((location) {
          location.createdAt = location.createdAt.toLocal();
        });
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error fetchAndSetLocationHistory: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<int> sendLocation({
    @required double latitude,
    @required double longitude,
    @required String token,
  }) async {
    return await sendLocationWithoutCheck(
      latitude,
      longitude,
      token,
    );
  }

  Future<void> sendLocationUser({
    @required List<int> adminIds,
    @required int operatorId,
    @required double latitude,
    @required double longitude,
    @required String token,
  }) async {
    sendLocationWithCheck(
      adminIds: adminIds,
      operatorId: operatorId,
      latitude: latitude,
      longitude: longitude,
      token: token,
    );
  }

  Future<void> getCurrentOwnLocation({
    @required int operatorId,
    @required String token,
  }) async {
    http.Response response;
    try {
      response = await http.get(
        URL.getCurrentLocation(operatorId: operatorId),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        final location = Location.fromJson(json.decode(response.body)["data"]);
        location.createdAt = location.createdAt.toLocal();
        location.operatorId = operatorId;
        currentLocation = location;
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error getCurrentOwnLocation: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> getAllCurrentLocation({
    @required String token,
    List<int> operatorIds,
  }) async {
    http.Response response;
    currentOperatorLocations.clear();
    try {
      for (int operatorId in operatorIds) {
        response = await http.get(
          URL.getCurrentLocation(operatorId: operatorId),
          headers: URL.jsonHeader(token: token),
        );
        if (response.statusCode == 200) {
          final location =
              Location.fromJson(json.decode(response.body)["data"]);
          location.createdAt = location.createdAt.toLocal();
          location.operatorId = operatorId;
          currentOperatorLocations.add(location);
        }
      }
      notifyListeners();
      return;
    } catch (error) {
      print(error);
      throw Exception('Lokasyon bilgisi gönderimi işlemi ' +
          'esnasında bilinmeyen ' +
          'bir hata meydana geldi.\n' +
          'Lütfen internet bağlantınız olduğundan emin olunuz.');
    }
  }

  Future<void> prepareLocationHistoriesPoints() async {
    if (historyLocationBig.length >= 2) {
      double sum50 = 0;
      double sum500 = 0;
      historyLocationSmall = [];
      historyLocationMedium = [];
      historyLocationSmall.add(historyLocationBig.first);
      historyLocationMedium.add(historyLocationBig.first);
      historyLocationBorder.add(historyLocationBig.first);
      historyLocationBorder.add(historyLocationBig.last);
      Location previous;
      double distance;
      for (final element in historyLocationBig
          .getRange(0, historyLocationBig.length - 1)
          .toList()) {
        if (sum50 >= 50) {
          historyLocationSmall.add(element);
          sum50 = 0;
        }
        if (sum500 >= 500) {
          historyLocationMedium.add(element);
          sum500 = 0;
        }
        if (previous == null) {
          previous = element;
        } else {
          distance = await Geolocator().distanceBetween(
            previous.latitude,
            previous.longitude,
            element.latitude,
            element.longitude,
          );
          sum50 += distance;
          sum500 += distance;
          previous = element;
        }
      }
      historyLocationSmall.add(
        historyLocationBig.last,
      );
      historyLocationMedium.add(
        historyLocationBig.last,
      );
    }
  }

  Location getCurrentOwnLocationWithTime() {
    return currentLocation;
  }

  LatLng getCurrentOwnLocationWithoutTime() {
    try {
      final position = LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      );
      return position;
    } catch (error) {
      print("Error getCurrentOwnLocationWithoutTime: $error");
      return null;
    }
  }

  Location getCurrentOperatorLocationWithTime() {
    try {
      return currentOperatorLocations[0];
    } catch (error) {
      print("Error getCurrentOperatorLocationWithTime: $error");
      return null;
    }
  }

  LatLng getCurrentOperatorLocationWithoutTime() {
    try {
      final position = LatLng(
        currentOperatorLocations[0].latitude,
        currentOperatorLocations[0].longitude,
      );
      return position;
    } catch (error) {
      print("Error getCurrentOperatorLocationWithoutTime: $error");
      return null;
    }
  }

  LatLng makeCurrentLocationToMapCenter({@required isAdmin}) {
    if (!isAdmin)
      return getCurrentOwnLocationWithoutTime();
    else
      return getCurrentOperatorLocationWithoutTime();
  }

  LatLng getLastHistoryLocationInCacheWithoutTime() {
    try {
      final position = LatLng(
        historyLocationBorder[1].latitude,
        historyLocationBorder[1].longitude,
      );
      return position;
    } catch (error) {
      print('Error getLastHistoryLocationInCacheWithoutTime: $error');
      print(error);
      return null;
    }
  }

  LatLng getFirstHistoryLocationInCacheWithoutTime() {
    try {
      final position = LatLng(
        historyLocationBorder[0].latitude,
        historyLocationBorder[0].longitude,
      );
      return position;
    } catch (error) {
      print('Error getFirstHistoryLocationInCacheWithoutTime: $error');
      print(error);
      return null;
    }
  }

  void updateLocalCurrentLocation(Location location) {
    bool isLocationExist = false;
    location.createdAt = location.createdAt.toLocal();
    currentOperatorLocations = currentOperatorLocations.map((element) {
      if (element.operatorId == location.operatorId) {
        isLocationExist = true;
        return location;
      }
      return element;
    }).toList();
    if (!isLocationExist) currentOperatorLocations.add(location);
    notifyListeners();
  }
}

Future<int> sendLocationWithoutCheck(
  double latitude,
  double longitude,
  String token,
) async {
  final response = await http.post(
    URL.postLocation(),
    body: json.encode(
      {
        "data": {
          "latitude": latitude,
          "longitude": longitude,
        },
      },
    ),
    headers: URL.jsonHeader(token: token),
  );
  int id = json.decode(response.body)["data"]["id"];
  return id;
}

Future<void> sendLocationWithCheck({
  @required List<int> adminIds,
  @required int operatorId,
  @required double latitude,
  @required double longitude,
  @required String token,
}) async {
  http.Response response;
  Future<void> sendLocation() async {
    response = await http.post(
      URL.postLocationUser(),
      body: json.encode(
        {
          "data": {
            "adminIds": adminIds,
            "operatorId": operatorId,
            "location": {
              "latitude": latitude,
              "longitude": longitude,
            }
          },
        },
      ),
      headers: URL.jsonHeader(token: token),
    );
  }

  try {
    final result = await OfflineLocationStorage.getLocation();
    if (result == null) {
      await sendLocation();
      if (response.statusCode == 200) return;
    } else {
      response = await http.post(
        URL.postLocationsUser(),
        body: json.encode(
          {
            "data": {
              "adminIds": adminIds,
              "operatorId": operatorId,
              "locations": result.map((e) => e.toJson()).toList(),
            },
          },
        ),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        OfflineLocationStorage.deleteLocation();
        await sendLocation();
      }
    }
  } catch (error) {
    print(error);
    OfflineLocationStorage.addLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
