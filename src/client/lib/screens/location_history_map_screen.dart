// import 'dart:async';

// import 'package:dgcs_gps/utilities/show_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong/latlong.dart';
// import 'package:map_controller/map_controller.dart';
// import 'package:provider/provider.dart';

// import '../models/location.dart';
// import '../providers/location.dart';
// import '../providers/users.dart';
// import '../utilities/zoom_level_timer.dart';
// import '../widgets/progress.dart';

// class LocationHistoryMap extends StatefulWidget {
//   final int operatorId;
//   final int duration;
//   LocationHistoryMap({
//     @required this.operatorId,
//     @required this.duration,
//   });

//   @override
//   _LocationHistoryMapState createState() => _LocationHistoryMapState();
// }

// class _LocationHistoryMapState extends State<LocationHistoryMap> {
//   final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
//   LocationProvider _locationProvider;
//   MapController _mapController;
//   StatefulMapController _statefulMapController;
//   ZoomLevelTimer zoomLevelTimer;
//   double _zoomLevel = 10;
//   int _previousZoomChange = 0;
//   int _isZoomChange = 0;
//   bool _isLoading = true;
//   @override
//   void initState() {
//     super.initState();
//     _locationProvider = Provider.of<LocationProvider>(
//       context,
//       listen: false,
//     );
//     fetchHistory();
//   }

//   @override
//   void dispose() {
//     zoomLevelTimer?.cancelZoomTimer();
//     super.dispose();
//   }

//   Future<void> fetchHistory() async {
//     try {
//       await _locationProvider.fetchAndSetLocationHistory(
//         operatorId: widget.operatorId,
//         token: Provider.of<UserProvider>(
//           context,
//           listen: false,
//         ).token,
//         duration: widget.duration,
//       );
//       if (_locationProvider.locationHistory.length < 1) {
//         notEnoughLocationData();
//         return;
//       }
//       await _locationProvider.prepareLocationHistoriesPoints();
//       _mapController = MapController();
//       _statefulMapController =
//           StatefulMapController(mapController: _mapController);
//       _statefulMapController.onReady.then((_) async {
//         await drawHistoryLine();
//         await drawHistoryPoint();
//         zoomLevelTimer = ZoomLevelTimer(
//           statefulMapController: _statefulMapController,
//           callback: (int value) async {
//             _previousZoomChange = _isZoomChange;
//             _isZoomChange = value;
//             await removeHistoryPoint();
//             await drawHistoryPoint();
//             setState(() {});
//           },
//         );
//         zoomLevelTimer.startZoomTimer();
//       });
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (error) {
//       print(error);
//       await Diaglog.show(
//         ctx: context,
//         withCancel: false,
//         title: "Konum İşlemi Hatası",
//         content: "Durum: ${error.toString()}",
//       );
//     }
//   }

//   void notEnoughLocationData() async {
//     await Diaglog.show(
//       ctx: context,
//       withCancel: false,
//       title: "Konum Geçmişi",
//       content: 'Kullanıcının yeterli konum geçmişi verisi bulunmamaktadır.',
//     );

//     Navigator.of(context).pop();
//   }

//   Future<void> drawHistoryLine() async {
//     await _statefulMapController.addLine(
//       name: 'locationHistory',
//       points: _locationProvider.locationHistory
//           .map((e) => LatLng(e.latitude, e.longitude))
//           .toList(),
//       color: Colors.black,
//     );
//     _statefulMapController.centerOnPoint(
//       _locationProvider.getFirstHistoryLocationInCacheWithoutTime(),
//     );
//   }

//   Future<void> drawHistoryPoint() async {
//     Widget builder(item) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Flexible(
//             child: Icon(
//               Icons.person_pin_circle,
//               color: Colors.blue,
//             ),
//           ),
//           if (_isZoomChange == 2 || _isZoomChange == 1)
//             Flexible(
//               child: Text(
//                 item.createdAt.toString().split(' ')[1].split('.')[0],
//                 softWrap: true,
//                 style: TextStyle(
//                   fontSize: 10,
//                 ),
//               ),
//             ),
//         ],
//       );
//     }

//     Map<String, Marker> markersBuilder(List<Location> array) {
//       return Map.fromIterable(
//         array,
//         key: (item) => item.id.toString(),
//         value: (item) => Marker(
//           height: _isZoomChange == 0
//               ? 25
//               : _isZoomChange == 1
//                   ? 50
//                   : 75,
//           width: _isZoomChange == 0
//               ? 25
//               : _isZoomChange == 1
//                   ? 50
//                   : 75,
//           point: LatLng(
//             item.latitude,
//             item.longitude,
//           ),
//           builder: (context) {
//             return builder(item);
//           },
//         ),
//       );
//     }

//     Map<String, Marker> markers;
//     if (_isZoomChange == 0)
//       markers = markersBuilder([
//         _locationProvider.firstHistory,
//         _locationProvider.lastHistory,
//       ]);
//     if (_isZoomChange == 1)
//       markers = markersBuilder(
//         _locationProvider.locationHistoryPoints500,
//       );
//     if (_isZoomChange == 2)
//       markers = markersBuilder(
//         _locationProvider.locationHistoryPoints100,
//       );

//     await _statefulMapController.addMarkers(markers: markers);
//     setState(() {});
//   }

//   Future<void> removeHistoryPoint() async {
//     if (_previousZoomChange == 0)
//       await _statefulMapController.removeMarkers(
//         names: [
//           _locationProvider.firstHistory,
//           _locationProvider.lastHistory,
//         ]
//             .map(
//               (e) => e.id.toString(),
//             )
//             .toList(),
//       );
//     if (_previousZoomChange == 1)
//       await _statefulMapController.removeMarkers(
//         names: _locationProvider.locationHistoryPoints500
//             .map(
//               (e) => e.id.toString(),
//             )
//             .toList(),
//       );
//     if (_previousZoomChange == 2)
//       await _statefulMapController.removeMarkers(
//         names: _locationProvider.locationHistoryPoints100
//             .map(
//               (e) => e.id.toString(),
//             )
//             .toList(),
//       );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Harita',
//           style: style.copyWith(color: Theme.of(context).accentColor),
//         ),
//       ),
//       body: Center(
//         child: _isLoading
//             ? Progress('Konum verileri alınıyor...')
//             : SafeArea(
//                 child: Stack(
//                   children: [
//                     FlutterMap(
//                       mapController: _mapController,
//                       options: MapOptions(
//                           center: _locationProvider
//                               .getLastHistoryLocationInCacheWithoutTime(),
//                           zoom: _zoomLevel,
//                           minZoom: 5,
//                           maxZoom: 18.49),
//                       layers: [
//                         new TileLayerOptions(
//                             urlTemplate:
//                                 "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                             subdomains: ['a', 'b', 'c']),
//                         PolylineLayerOptions(
//                           polylines: _statefulMapController.lines,
//                         ),
//                         MarkerLayerOptions(
//                           markers: _statefulMapController.markers,
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
