import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:business_travel/models/location.dart';
import 'package:business_travel/utilities/global_provider.dart';
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
  List<Location> historyLocation = [];
  List<Location> historyLocationBig = []; //100m
  List<Location> historyLocationMedium = []; //500m
  List<Location> historyLocationBorder = []; //first and last
  bool isAllowedBackgroundTracking = false;

  void settingsBackgroundTracking(
      {String token, int operatorId, int adminId}) async {
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
        try {
          if (data?.latitude != null && data?.longitude != null) {
            currentLocation = Location(
              latitude: data.latitude,
              longitude: data.longitude,
              createdAt: DateTime.now(),
              operatorId: operatorId,
            );
          }
          notifyListeners();
        } catch (error) {
          print("**********************************");
          print("Error locationListenerCalback: $error");
        }
      },
    );
    // print('Initializing...');
    await BackgroundLocator.initialize();
    // print('Initialization done');
    // final _isRunning = await BackgroundLocator.isServiceRunning();
    // print('Running $_isRunning');
  }

  void allowBackgroundTracking(
      {String token, int operatorId, int adminId}) async {
    OfflineLocationStorage.init();
    settingsBackgroundTracking(
        token: token, operatorId: operatorId, adminId: adminId);
    isAllowedBackgroundTracking = true;
    if (await LocationFunctions.checkLocationPermission()) {
      LocationFunctions.startLocator(
          token: token, operatorId: operatorId, adminId: adminId);
    } else {
      print("**************************************");
      print("Error allowBackgroundTracking permission denied");
    }
  }

  void deniedBackgroundTracking() {
    isAllowedBackgroundTracking = false;
    LocationFunctions.stopLocator();
  }

  void toogleBackgroundTracking() {
    if (isAllowedBackgroundTracking) {
      deniedBackgroundTracking();
    } else {
      allowBackgroundTracking();
    }
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
          startDate: startDate.toUtc(),
          finishDate: finishDate.toUtc(),
        ),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        historyLocation = [];
        json.decode(response.body)["data"]["locations"].forEach((e) {
          historyLocation.add(Location.fromJson(e));
        });
        // print("************************************");
        // print("History Location Length: ${historyLocation.length}");
        historyLocation.forEach((location) {
          location.createdAt = location.createdAt.toLocal();
        });
        historyLocation.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        notifyListeners();
        // print("************************************");
        // historyLocation.forEach((location) {
        //   print(location.toJson());
        // });
        return;
      }
    } catch (error) {
      print("Error fetchAndSetLocationHistory: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  List<Location> filterLocationByDate({
    DateTime taskStartDate,
    int historyDay,
  }) {
    DateTime startDate = taskStartDate.add(Duration(days: historyDay - 1));
    DateTime finishDate = taskStartDate.add(Duration(days: historyDay));
    // print("***********************************");
    // print("startDate: ${startDate.toIso8601String()}");
    // print("finishDate: ${finishDate.toIso8601String()}");
    final array = historyLocation
        .where((element) =>
            element.createdAt.isAfter(startDate) &&
            element.createdAt.isBefore(finishDate))
        .toList();
    // print("***********************************");
    // print("filterLocationByDate: filteredLocations length: ${array.length}");
    return array;
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

  Future<void> getCurrentLocation({
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

  Future<void> prepareLocationHistoriesPoints(List<Location> history) async {
    if (history.length >= 2) {
      double sum500 = 0;
      double sum100 = 0;
      historyLocationBig = [];
      historyLocationMedium = [];
      historyLocationBorder = [];
      historyLocationBig.add(history.first);
      historyLocationMedium.add(history.first);
      historyLocationBorder.add(history.first);
      Location previous;
      double distance;
      for (final element in history.getRange(0, history.length - 1).toList()) {
        if (sum100 >= 100) {
          historyLocationBig.add(element);
          sum100 = 0;
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
          sum500 += distance;
          sum100 += distance;
          previous = element;
        }
      }
      historyLocationBig.add(history.last);
      historyLocationMedium.add(history.last);
      historyLocationBorder.add(history.last);
    } else {
      historyLocationBig = [];
      historyLocationMedium = [];
      historyLocationBorder = [];
    }
  }

  List<Location> locationsBetweenPoints(Location begin, Location end) {
    List<Location> locations = [];
    historyLocation.forEach((element) {
      if (element.id >= begin.id && element.id <= end.id) {
        locations.add(element);
      }
    });
    return locations;
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
      return currentLocation;
    } catch (error) {
      print("Error getCurrentOperatorLocationWithTime: $error");
      return null;
    }
  }

  LatLng getCurrentOperatorLocationWithoutTime() {
    try {
      final position = LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
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
    location.createdAt = location.createdAt.toLocal();
    if (currentLocation.operatorId == location.operatorId) {
      currentLocation = location;
      notifyListeners();
    }
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
  @required int adminId,
  @required int operatorId,
  @required double latitude,
  @required double longitude,
  @required DateTime createdAt,
  @required String token,
}) async {
  http.Response response;
  // print("***************************");
  // print(
  //     "send LocationWithCheck Info: $adminId $operatorId $latitude $longitude ${createdAt.toIso8601String()} $token");
  try {
    final result = await OfflineLocationStorage.getLocation();
    if (result.length == 0) {
      await safeSendLocation(
        adminId: adminId,
        operatorId: operatorId,
        latitude: latitude,
        longitude: longitude,
        createdAt: createdAt,
        token: token,
      );
      return;
    } else {
      response = await http.post(
        URL.postUserLocations(),
        body: json.encode(
          {
            "data": {
              "adminId": adminId,
              "operatorId": operatorId,
              "locations": result.map((e) => e.toJson()).toList(),
            },
          },
        ),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        OfflineLocationStorage.deleteLocation();
        await safeSendLocation(
          adminId: adminId,
          operatorId: operatorId,
          latitude: latitude,
          longitude: longitude,
          createdAt: createdAt,
          token: token,
        );
      }
    }
  } catch (error) {
    print("**********************************");
    print("Error sendLocationWithCheck: $error");
    OfflineLocationStorage.addLocation(
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
    );
  }
}

Future<void> safeSendLocation({
  @required int adminId,
  @required int operatorId,
  @required double latitude,
  @required double longitude,
  @required DateTime createdAt,
  @required String token,
}) async {
  if (MyProvider?.task?.existActiveTask() != null) {
    final distance = await Geolocator().distanceBetween(
      MyProvider.task.activeTask.location.latitude,
      MyProvider.task.activeTask.location.longitude,
      latitude,
      longitude,
    );
    if (!MyProvider.task.activeTask.isOperatorOnTask) {
      if (MyProvider.task.activeTask.radius * 1000 > distance) {
        MyProvider.task.updateTask(
          id: MyProvider.task.activeTask.id,
          operatorId: MyProvider.task.activeTask.operatorId,
          latitude: MyProvider.task.activeTask.location.latitude,
          longitude: MyProvider.task.activeTask.location.longitude,
          radius: MyProvider.task.activeTask.radius,
          startedAt: MyProvider.task.activeTask.startedAt,
          finishedAt: MyProvider.task.activeTask.finishedAt,
          description: MyProvider.task.activeTask.description,
          name: MyProvider.task.activeTask.name,
          isOperatorOnTask: !MyProvider.task.activeTask.isOperatorOnTask,
          token: MyProvider.user.token,
        );
      }
    } else {
      if (MyProvider.task.activeTask.radius * 1000 < distance) {
        MyProvider.task.updateTask(
          id: MyProvider.task.activeTask.id,
          operatorId: MyProvider.task.activeTask.operatorId,
          latitude: MyProvider.task.activeTask.location.latitude,
          longitude: MyProvider.task.activeTask.location.longitude,
          radius: MyProvider.task.activeTask.radius,
          startedAt: MyProvider.task.activeTask.startedAt,
          finishedAt: MyProvider.task.activeTask.finishedAt,
          description: MyProvider.task.activeTask.description,
          name: MyProvider.task.activeTask.name,
          isOperatorOnTask: !MyProvider.task.activeTask.isOperatorOnTask,
          token: MyProvider.user.token,
        );
      }
    }
  }
  await http.post(
    URL.postUserLocation(),
    body: json.encode(
      {
        "data": {
          "adminIds": adminId,
          "operatorId": operatorId,
          "location": {
            "latitude": latitude,
            "longitude": longitude,
            "createdAt": createdAt.toUtc().toIso8601String(),
          }
        },
      },
    ),
    headers: URL.jsonHeader(token: token),
  );
}
