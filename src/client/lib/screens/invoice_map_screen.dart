import 'dart:async';

import 'package:business_travel/models/location.dart';
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

class InvoiceMapScreen extends StatefulWidget {
  final int operatorId;
  final DateTime taskStartDate;
  final DateTime taskEndDate;
  final Location taskLocation;

  InvoiceMapScreen(
      {@required this.operatorId,
      @required this.taskStartDate,
      @required this.taskEndDate,
      @required this.taskLocation});

  @override
  _InvoiceMapScreenState createState() => _InvoiceMapScreenState();
}

class _InvoiceMapScreenState extends State<InvoiceMapScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  LocationProvider _locationProvider;
  UserProvider _userProvider;
  MapController _mapController;
  StatefulMapController _statefulMapController;
  ZoomLevelTimer _zoomLevelTimer;
  double _zoomLevel = 10;
  int _isZoomChange = 0;
  int _historyDay = 1;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    _userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    fetchHistory();
  }

  @override
  void dispose() {
    _zoomLevelTimer?.cancelZoomTimer();
    super.dispose();
  }

  Future<void> fetchHistory() async {
    setState(() {
      _isLoading = true;
    });
    _mapController = MapController();
    _statefulMapController =
        StatefulMapController(mapController: _mapController);
    try {
      await _locationProvider.fetchAndSetLocationHistory(
        operatorId: widget.operatorId,
        startDate: widget.taskStartDate,
        finishDate: widget.taskEndDate,
        token: _userProvider.token,
      );

      _statefulMapController.onReady.then((_) async {
        _select(_historyDay.toString());
        _zoomLevelTimer = ZoomLevelTimer(
          statefulMapController: _statefulMapController,
          callback: (int value) async {
            _isZoomChange = value;
            await removeMarkers();
            await addHistoryPoint();
            await addHistoryLine();
            setState(() {});
          },
        );
        _zoomLevelTimer.startZoomTimer();
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
            child: GestureDetector(
              child: Icon(
                Icons.location_history,
                color: Colors.blue,
              ),
              onTap: () {
                Navigator.of(context).pop<Location>(item);
              },
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
  }

  Future<void> removeMarkers() async {
    List<String> markers;
    markers = _locationProvider.historyLocationBig
        .map((e) => e.id.toString())
        .toList();
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
      taskStartDate: widget.taskStartDate,
      historyDay: _historyDay,
    ));
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
                widget.taskEndDate.difference(widget.taskStartDate).inDays,
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
                          center: LatLng(
                            widget.taskLocation.latitude,
                            widget.taskLocation.longitude,
                          ),
                          zoom: _zoomLevel,
                          minZoom: 5,
                          maxZoom: 18.49),
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
