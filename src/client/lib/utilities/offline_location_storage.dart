import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/location.dart';

class OfflineLocationStorage {
  static const String dbName = "location_stored";
  static bool isReady = false;
  static Database db;

  static Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, dbName);
    db = await openDatabase(path);
    await db.execute('CREATE TABLE IF NOT EXISTS location ' +
        '(id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        ' latitude REAL,' +
        ' longitude REAL,' +
        ' createdAt TEXT)');
    await db.delete('location');

    isReady = true;
  }

  static Future<List<Location>> getLocation() async {
    if (isReady) {
      List<Location> result = [];
      List<dynamic> list = await db.rawQuery('SELECT * FROM location');
      list.forEach((e) {
        result.add(
          Location(
            latitude: e["latitude"] as double,
            longitude: e["longitude"] as double,
            createdAt: DateTime.tryParse(e["createdAt"]),
          ),
        );
      });

      if (result.length != 0) return result;
    }
    return [];
  }

  static Future<void> addLocation({
    double latitude,
    double longitude,
  }) async {
    if (isReady) {
      await db.transaction((txn) async {
        int id = await txn.rawInsert(
            'INSERT INTO location(latitude, longitude, createdAt) ' +
                'VALUES($latitude,' +
                ' $longitude,' +
                ' "${DateTime.now().toUtc().toIso8601String()}")');
        print('addLocation: $id');
      });
    }
  }

  static Future<void> deleteLocation() async {
    int count = await db.delete('location', where: null);
    print('deleteLocation: $count');
  }
}
