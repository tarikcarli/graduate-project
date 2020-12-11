import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';

class TaskLocationMap extends StatefulWidget {
  @override
  _TaskLocationMapState createState() => _TaskLocationMapState();
}

class _TaskLocationMapState extends State<TaskLocationMap> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  MapController _mapController;
  StatefulMapController _statefulMapController;
  StreamSubscription<StatefulMapControllerStateChange> _sub;

  LatLng _center;
  Timer timer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _statefulMapController =
        StatefulMapController(mapController: _mapController);

    _statefulMapController.onReady.then((_) {
      _sub = _statefulMapController.changeFeed.listen((change) {
        setState(() {});
      });

      timer = new Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _center = _statefulMapController.center;
        _statefulMapController.addMarker(
            marker: Marker(
              point: _center,
              builder: (context) => Icon(
                Icons.location_on,
                color: Colors.deepOrange,
              ),
            ),
            name: 'taskLocation');
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Görev Konumunu belirle',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
      ),
      body: Center(
        child: SafeArea(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(40.786329, 29.446053),
              minZoom: 5,
              maxZoom: 18.49,
            ),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(
                markers: _statefulMapController.markers,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop(_statefulMapController.center);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add_location,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
