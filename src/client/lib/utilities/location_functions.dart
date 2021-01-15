import 'package:background_locator/background_locator.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:business_travel/utilities/location_callback_handler.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';

class LocationFunctions {
  static void startLocator(
      {@required String token,
      @required int adminId,
      @required int operatorId}) {
    double distanceFilter = 25;
    Map<String, dynamic> data = {
      'countInit': 1.toString(),
      "token": token,
      "adminId": adminId.toString(),
      "operatorId": operatorId.toString(),
    };
    BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
/*
        Comment initDataCallback, so service not set init variable,
        variable stay with value of last run after unRegisterLocationUpdate
 */
      disposeCallback: LocationCallbackHandler.disposeCallback,
      iosSettings: IOSSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          distanceFilter: distanceFilter),
      autoStop: false,
      androidSettings: AndroidSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        distanceFilter: distanceFilter,
        androidNotificationSettings: AndroidNotificationSettings(
          notificationChannelName: 'Location tracking',
          notificationTitle: 'Konum Verisi Alınıyor',
          notificationMsg: 'Lokasyon veriniz alınıyor.',
          notificationBigMsg:
              'Aktif görevde olduğunuz için şu anda konum veriniz alınmaktadır.',
          notificationIcon: '',
          notificationIconColor: Colors.blueAccent,
          notificationTapCallback: LocationCallbackHandler.notificationCallback,
        ),
      ),
    );
  }

  static Future<bool> checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }

  static void stopLocator() async {
    BackgroundLocator.unRegisterLocationUpdate();
  }
}
