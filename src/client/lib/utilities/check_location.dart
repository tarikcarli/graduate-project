import 'package:geolocator/geolocator.dart';

enum Permission {
  NoGps,
  NoPermission,
  Available,
}

Future<Permission> checkPermission(Geolocator geolocator) async {
  GeolocationStatus geolocationStatus =
      await geolocator.checkGeolocationPermissionStatus();
  if (geolocationStatus == GeolocationStatus.denied ||
      geolocationStatus == GeolocationStatus.disabled ||
      geolocationStatus == GeolocationStatus.unknown) {
    return Permission.NoPermission;
  }

  bool serviceResult = await geolocator.isLocationServiceEnabled();
  if (!serviceResult) {
    return Permission.NoGps;
  }

  return Permission.Available;
}

Future<String> getPermission(bool isActive, Geolocator geolocator) async {
  if (isActive) {
    return null;
  }

  Permission permission = await checkPermission(geolocator);
  if (permission == Permission.Available) {
    return null;
  }
  String text = 'Uygulamanın kullanılabilmesi için ';
  if (permission == Permission.NoPermission) {
    text +=
        'telefonda uygulama için gerekli izinlerin verilmiş olması gerekir.\n' +
            'Lütfen önce konum iznini her zaman olarak veriniz.';
  } else if (permission == Permission.NoGps)
    text += 'telefonda gps bağlantısının bulunması gerekmektedir.\n' +
        'Lütfen önce gps bağlantısını sağlayanız.';
  return text;
}
