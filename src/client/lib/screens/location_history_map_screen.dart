import 'dart:async';

import 'package:business_travel/models/location.dart';
import 'package:business_travel/models/task.dart';
import 'package:business_travel/models/user.dart';
import 'package:business_travel/providers/location.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/utilities/zoom_level_timer.dart';
import 'package:business_travel/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:provider/provider.dart';

class LocationHistoryMap extends StatefulWidget {
  final User user;
  final Task task;
  LocationHistoryMap({
    @required this.user,
    @required this.task,
  });

  @override
  _LocationHistoryMapState createState() => _LocationHistoryMapState();
}

class _LocationHistoryMapState extends State<LocationHistoryMap> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  LocationProvider _locationProvider;
  MapController _mapController;
  StatefulMapController _statefulMapController;
  int _historyDay = 1;

  ZoomLevelTimer zoomLevelTimer;
  double _zoomLevel = 10;
  int _isZoomChange = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    fetchHistory();
  }

  @override
  void dispose() {
    zoomLevelTimer?.cancelZoomTimer();
    super.dispose();
  }

  Future<void> fetchHistory() async {
    try {
      await _locationProvider.fetchAndSetLocationHistory(
        operatorId: widget.user.id,
        token: Provider.of<UserProvider>(
          context,
          listen: false,
        ).token,
        startDate: widget.task.startedAt,
        finishDate: widget.task.finishedAt,
      );
      await _locationProvider.prepareLocationHistoriesPoints(
        _locationProvider.filterLocationByDate(
          taskStartDate: widget.task.startedAt,
          historyDay: _historyDay,
        ),
      );
      _mapController = MapController();
      _statefulMapController =
          StatefulMapController(mapController: _mapController);
      _statefulMapController.onReady.then((_) async {
        _statefulMapController.centerOnPoint(
          LatLng(
            widget.task.location.latitude,
            widget.task.location.longitude,
          ),
        );
        await addHistoryLine();
        await addHistoryPoint();
        zoomLevelTimer = ZoomLevelTimer(
          statefulMapController: _statefulMapController,
          callback: (int value) async {
            _isZoomChange = value;
            await removeMarkers();
            await addHistoryPoint();
            await addHistoryLine();
            setState(() {});
          },
        );
        zoomLevelTimer.startZoomTimer();
      });
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      await CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "Konum İşlemi Hatası",
        content: "Durum: ${error.toString()}",
      );
    }
  }

  Future<void> addHistoryLine() async {
    // print("************************************");
    // _locationProvider.historyLocationBig.forEach((location) {
    //   print(location.toJson());
    // });
    await _statefulMapController.addLine(
      name: 'locationHistory',
      points: _locationProvider.historyLocationBig
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList(),
      color: Colors.black,
    );
  }

  Future<void> addHistoryPoint() async {
    Widget builder(item) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Icon(
              Icons.location_history,
              color: Colors.blue,
            ),
          ),
          if (_isZoomChange == 2 || _isZoomChange == 1)
            Flexible(
              child: Text(
                item.createdAt.toString().split(' ')[1].split('.')[0],
                softWrap: true,
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
        ],
      );
    }

    Map<String, Marker> markersBuilder(List<Location> array) {
      return Map.fromIterable(
        array,
        key: (item) => item.id.toString(),
        value: (item) => Marker(
          height: _isZoomChange == 0
              ? 25
              : _isZoomChange == 1
                  ? 50
                  : 75,
          width: _isZoomChange == 0
              ? 25
              : _isZoomChange == 1
                  ? 50
                  : 75,
          point: LatLng(
            item.latitude,
            item.longitude,
          ),
          builder: (context) {
            return builder(item);
          },
        ),
      );
    }

    Map<String, Marker> markers;
    if (_isZoomChange == 0)
      markers = markersBuilder(_locationProvider.historyLocationBorder);
    if (_isZoomChange == 1)
      markers = markersBuilder(_locationProvider.historyLocationMedium);
    if (_isZoomChange == 2)
      markers = markersBuilder(_locationProvider.historyLocationBig);

    await _statefulMapController.addMarkers(markers: markers);
    setState(() {});
  }

  Future<void> removeMarkers() async {
    List<String> markers;
    markers =
        _locationProvider.historyLocation.map((e) => e.id.toString()).toList();
    await _statefulMapController.removeMarkers(names: markers);
  }

  Future<void> removePolyline() async {
    await _statefulMapController.removeLine("locationHistory");
  }

  void _select(String value) async {
    await removePolyline();
    await removeMarkers();
    _historyDay = int.tryParse(value);
    await _locationProvider
        .prepareLocationHistoriesPoints(_locationProvider.filterLocationByDate(
      taskStartDate: widget.task.startedAt,
      historyDay: _historyDay,
    ));
    // print("*******************************");
    // print(
    //     "For _HistoryDay $_historyDay: historyLocation length: ${_locationProvider.historyLocation.length}");
    // print(
    //     "For _HistoryDay $_historyDay: historyLocationBorder length: ${_locationProvider.historyLocationBorder.length}");
    // print(
    //     "For _HistoryDay $_historyDay: historyLocationMedium length: ${_locationProvider.historyLocationMedium.length}");
    // print(
    //     "For _HistoryDay $_historyDay: historyLocationBig length: ${_locationProvider.historyLocationBig.length}");
    await addHistoryPoint();
    await addHistoryLine();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Harita',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _select,
            initialValue: _historyDay.toString(),
            itemBuilder: (BuildContext context) {
              return List<Map<String, String>>.generate(
                widget.task.finishedAt.difference(widget.task.startedAt).inDays,
                (index) => {
                  "value": (index + 1).toString(),
                  "display": "${index + 1}. Gün",
                },
              ).map((Map<String, String> element) {
                return PopupMenuItem<String>(
                  value: element["value"],
                  child: Text(
                    element["display"],
                    style: _historyDay.toString() == element["value"]
                        ? style.copyWith(color: Theme.of(context).primaryColor)
                        : style,
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? ProgressWidget()
            : SafeArea(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        zoom: _zoomLevel,
                        minZoom: 5,
                        maxZoom: 18.49,
                      ),
                      layers: [
                        new TileLayerOptions(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c']),
                        PolylineLayerOptions(
                          polylines: _statefulMapController.lines,
                        ),
                        MarkerLayerOptions(
                          markers: _statefulMapController.markers,
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
