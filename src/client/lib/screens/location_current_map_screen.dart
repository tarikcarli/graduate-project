import 'package:business_travel/models/location.dart';
import 'package:business_travel/providers/location.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/tasks_screen.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:business_travel/utilities/zoom_level_timer.dart';
import 'package:business_travel/widgets/drawer_widget.dart';
import 'package:business_travel/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:provider/provider.dart';

class LocationCurrentMap extends StatefulWidget {
  LocationCurrentMap({
    @required this.operatorId,
    this.isAdmin = true,
  });
  final int operatorId;
  final bool isAdmin;
  @override
  _LocationCurrentMapState createState() => _LocationCurrentMapState();
}

class _LocationCurrentMapState extends State<LocationCurrentMap> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  UserProvider _userProvider;
  LocationProvider _locationProvider;
  MapController _mapController;
  StatefulMapController _statefulMapController;
  String _previousLocationNames;

  ZoomLevelTimer _zoomLevelTimer;
  int _isZoomChange = 0;
  double _zoomLevel = 11;
  bool _isLoading = true;
  bool _fistLoading = true;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    print('operatorId : ${widget.operatorId}');
  }

  @override
  void dispose() {
    _locationProvider?.removeListener(currentLocationToState);
    _zoomLevelTimer?.cancelZoomTimer();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fistLoading) {
      _fistLoading = false;
      asyncInitFunction();
    }
  }

  Future<void> asyncInitFunction() async {
    try {
      _locationProvider = Provider.of<LocationProvider>(context);
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      _locationProvider.addListener(currentLocationToState);

      await _locationProvider.getCurrentLocation(
        operatorId: widget.operatorId,
        token: _userProvider.token,
      );
      if (_locationProvider.currentLocation == null) {
        throw Exception("");
      }

      _mapController = MapController();
      _statefulMapController =
          StatefulMapController(mapController: _mapController);
      _statefulMapController.onReady.then((_) async {
        _isMapReady = true;
        _zoomLevelTimer = ZoomLevelTimer(
          statefulMapController: _statefulMapController,
          callback: (int value) async {
            _isZoomChange = value;

            await addUserLocation();
          },
        );
        _statefulMapController.centerOnPoint(
          LatLng(
            _locationProvider.currentLocation.latitude,
            _locationProvider.currentLocation.longitude,
          ),
        );
        _zoomLevelTimer.startZoomTimer();
        await addUserLocation();
      });
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      await CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "Konum Verisi",
        content:
            "${_userProvider.operatorIdToName(widget.operatorId)} kullanıcısının konum verisi bulunamadı",
      );
      if (_userProvider.user.role == "operator")
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => TasksScreen(),
          ),
        );
      else
        Navigator.pop(context);
    }
  }

  void currentLocationToState() {
    if (_isMapReady) {
      if (_previousLocationNames != null)
        _statefulMapController.removeMarker(name: _previousLocationNames);
      addUserLocation();
    }
  }

  Future<void> addUserLocation() async {
    Widget builder(location) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0))),
                    child: Container(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.network(
                            URL.getBinaryPhoto(
                              path: _userProvider
                                  .finByOperatorId(widget.operatorId)
                                  .photo
                                  .path,
                            ),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.location_on,
                color: Colors.blue,
              ),
            ),
          ),
          if (_isZoomChange == 1 || _isZoomChange == 2)
            Flexible(
              child: Text(
                _userProvider.operatorIdToName(location.operatorId),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          if (_isZoomChange == 2)
            Flexible(
              child: Text(
                location.createdAt.toString().split(' ')[1].split('.')[0],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
        key: (location) => 'user${location.operatorId}',
        value: (location) => Marker(
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
            location.latitude,
            location.longitude,
          ),
          builder: (context) {
            return builder(location);
          },
        ),
      );
    }

    List<Location> userList = [];
    userList.add(_locationProvider.currentLocation);
    Map<String, Marker> markers = markersBuilder(userList);
    _previousLocationNames = markers.keys.toList()[0];
    await _statefulMapController.addMarkers(markers: markers);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Harita',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
      ),
      drawer: widget.isAdmin ? null : DrawerWidget(),
      body: _isLoading
          ? ProgressWidget()
          : Center(
              child: SafeArea(
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
                        MarkerLayerOptions(
                          markers: _statefulMapController.markers,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
