// import 'package:dgcs_gps/utilities/image_convert.dart';
// import 'package:dgcs_gps/utilities/show_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong/latlong.dart';
// import 'package:map_controller/map_controller.dart';
// import 'package:provider/provider.dart';

// import './single_task_screen.dart';
// import './update_task_screen.dart';
// import '../models/location.dart';
// import '../models/task.dart';
// import '../providers/location.dart';
// import '../providers/tasks.dart';
// import '../providers/users.dart';
// import '../utilities/zoom_level_timer.dart';
// import '../widgets/progress.dart';

// class LocationCurrentMap extends StatefulWidget {
//   LocationCurrentMap({
//     @required this.allOperatorId,
//   });
//   final List<int> allOperatorId;
//   @override
//   _LocationCurrentMapState createState() => _LocationCurrentMapState();
// }

// class _LocationCurrentMapState extends State<LocationCurrentMap> {
//   final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
//   TaskProvider _tasksProvider;
//   UserProvider _userProvider;
//   LocationProvider _locationProvider;
//   MapController _mapController;
//   StatefulMapController _statefulMapController;
//   List<String> _previousLocationNames;
//   List<String> _previousTaskNames;

//   ZoomLevelTimer _zoomLevelTimer;
//   int _isZoomChange = 0;
//   double _zoomLevel = 11;
//   bool _isLoading = true;
//   bool _firstUser = true;
//   bool _providerWithoutListen = true;
//   bool _isMapReady = false;

//   @override
//   void initState() {
//     super.initState();
//     print('allOperatorId : ${widget.allOperatorId}');
//   }

//   @override
//   void dispose() {
//     _locationProvider?.removeListener(currentLocationToState);
//     _tasksProvider.removeListener(currentTaskToState);
//     _zoomLevelTimer?.cancelZoomTimer();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (_providerWithoutListen) {
//       _providerWithoutListen = false;
//       asyncInitFunction();
//     }
//   }

//   Future<void> asyncInitFunction() async {
//     try {
//       _locationProvider = Provider.of<LocationProvider>(context);
//       _tasksProvider = Provider.of<TaskProvider>(context);
//       _userProvider = Provider.of<UserProvider>(context, listen: false);
//       _locationProvider.addListener(currentLocationToState);
//       _tasksProvider.addListener(currentTaskToState);

//       if (widget.allOperatorId != null) {
//         await _locationProvider.getAllCurrentLocation(
//           token: _userProvider.token,
//           allOperatorId: widget.allOperatorId,
//         );
//         if (_locationProvider.currentOperatorLocation.length == 0) {
//           await notEnoughLocationData();
//           return;
//         }
//       }

//       if (widget.allOperatorId == null) {
//         await _locationProvider.getCurrentOwnLocation(
//           operatorId: _userProvider.user.id,
//           token: _userProvider.token,
//         );
//         if (_locationProvider.currentOwnLocation == null) {
//           await notEnoughLocationData();
//           return;
//         }
//       }
//       if (_userProvider.user.role == "admin")
//         await _tasksProvider.fetchAndSetTasks(
//           token: _userProvider.token,
//           adminId: _userProvider.user.id,
//         );
//       else
//         await _tasksProvider.fetchAndSetTasks(
//           token: _userProvider.token,
//           operatorId: _userProvider.user.id,
//         );
//       _mapController = MapController();
//       _statefulMapController =
//           StatefulMapController(mapController: _mapController);
//       _statefulMapController.onReady.then((_) async {
//         _isMapReady = true;
//         _zoomLevelTimer = ZoomLevelTimer(
//           statefulMapController: _statefulMapController,
//           callback: (int value) async {
//             _isZoomChange = value;
//             await addTaskPoints();
//             await addUserLocation();
//           },
//         );
//         _zoomLevelTimer.startZoomTimer();
//         await addTaskPoints();
//         await addUserLocation();
//       });
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (error) {
//       await Diaglog.show(
//         ctx: context,
//         withCancel: false,
//         title: "Görevleri Alma İşlemi Hatası",
//         content: "Durum: ${error.toString()}",
//       );
//     }
//   }

//   Future<void> notEnoughLocationData() async {
//     String text = 'Kullanıcının konum verisi bulunduğundan eminseniz,' +
//         'lütfen internet bağlantınızı ve internet hızınızı kontrol ediniz.';

//     await Diaglog.show(
//       ctx: context,
//       withCancel: false,
//       title: "Konum Verisi",
//       content: widget.allOperatorId != null
//           ? 'Kullanıcının veya kullanıcıların verisi bulunmamaktadır..\n$text'
//           : 'Yeterli veriniz bulunmamaktadır..\n$text',
//     );

//     Navigator.of(context).pop();
//   }

//   void currentLocationToState() {
//     if (_isMapReady) {
//       if (_previousLocationNames != null)
//         _statefulMapController.removeMarkers(names: _previousLocationNames);
//       addUserLocation();
//     }
//   }

//   void currentTaskToState() {
//     if (_isMapReady) {
//       if (_previousTaskNames != null)
//         _statefulMapController.removeMarkers(names: _previousTaskNames);
//       addTaskPoints();
//     }
//   }

//   Future<void> addTaskPoints() async {
//     Widget builder(BuildContext context, Task responseTaskModel) {
//       final myIcon = GestureDetector(
//         onTap: () => markerOnTab(responseTaskModel),
//         child: Icon(
//           responseTaskModel.isComplete ? Icons.check_circle : Icons.add_a_photo,
//           color: responseTaskModel.isComplete ? Colors.green : Colors.red,
//         ),
//       );
//       if (_isZoomChange == 2 || _isZoomChange == 1)
//         return Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Flexible(
//               child: Text(
//                 responseTaskModel.name,
//                 style: TextStyle(
//                   fontSize: 10,
//                 ),
//                 textAlign: TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             if (_isZoomChange == 2)
//               Flexible(
//                 child: Text(
//                   responseTaskModel.createdAt.toString().split(' ')[0],
//                   style: TextStyle(
//                     fontSize: 10,
//                   ),
//                   textAlign: TextAlign.center,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             myIcon,
//           ],
//         );
//       else {
//         return myIcon;
//       }
//     }

//     Map<String, Marker> markersBuilder(List<Task> array) {
//       return Map.fromIterable(
//         array,
//         key: (item) => 'task${item.id.toString()}',
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
//             item.location.latitude,
//             item.location.longitude,
//           ),
//           builder: (BuildContext context) => builder(context, item),
//         ),
//       );
//     }

//     List<Task> tasks = [];
//     if (widget?.allOperatorId?.length == 1)
//       _tasksProvider.tasks.forEach(
//         (element) {
//           if (element.operatorId == widget.allOperatorId[0]) tasks.add(element);
//         },
//       );
//     else
//       tasks = _tasksProvider.tasks;

//     final markers = markersBuilder(tasks);
//     _previousTaskNames = markers.keys.toList();
//     await _statefulMapController.addMarkers(markers: markers);
//     if (mounted) setState(() {});
//   }

//   Future<void> markerOnTab(Task task) async {
//     if (_userProvider.user.role == "operator") {
//       if (task.isComplete) {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => SingleTaskScreen(
//               task: task,
//               operatorFullName:
//                   '${_userProvider.user.firstName} ${_userProvider.user.lastName}',
//             ),
//           ),
//         );
//       } else {
//         LatLng currentLocation =
//             _locationProvider.getCurrentOwnLocationWithoutTime();
//         double distance = await _locationProvider.geolocator.distanceBetween(
//           currentLocation.latitude,
//           currentLocation.longitude,
//           task.location.latitude,
//           task.location.longitude,
//         );
//         if (distance < 100) {
//           await Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => EditTask(
//                 task: task,
//                 token: _userProvider.token,
//               ),
//             ),
//           );
//           addTaskPoints();
//         } else {
//           await Diaglog.show(
//             ctx: context,
//             withCancel: false,
//             title: "Konum Yakınlığı",
//             content: 'Görevi görüntüleyebilmek için en az ' +
//                 '100 metre yakınında olmalısınız. \n' +
//                 'Göreve uzaklığınız ${distance.toInt()} metredir.\n' +
//                 'Lütfen ${(distance - 100).toInt()} metre yaklaştıktan ' +
//                 'sonra tekrar deneyiniz.',
//           );
//         }
//       }
//     } else {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => SingleTaskScreen(
//             task: task,
//             operatorFullName: _userProvider.userIdToUserName(task.operatorId),
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> addUserLocation() async {
//     Widget builder(location) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Flexible(
//             child: GestureDetector(
//               onTap: () async {
//                 await showDialog(
//                   context: context,
//                   builder: (_) => Dialog(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(32.0))),
//                     child: Container(
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).pop();
//                         },
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(32),
//                           child: Image.memory(
//                             ImageConvert.dataFromBase64String(
//                               _userProvider.userIdToPhoto(
//                                 location.operatorId,
//                               ),
//                             ),
//                             fit: BoxFit.cover,
//                             width: MediaQuery.of(context).size.width * 0.8,
//                             height: MediaQuery.of(context).size.height * 0.5,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               child: Icon(
//                 Icons.person_pin_circle,
//                 color: Colors.blue,
//               ),
//             ),
//           ),
//           if (_isZoomChange == 1 || _isZoomChange == 2)
//             Flexible(
//               child: Text(
//                 _userProvider.user.id == location.operatorId
//                     ? _userProvider.user.firstName
//                     : _userProvider
//                         .userIdToUserName(location.operatorId)
//                         .split(' ')[0],
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 10,
//                 ),
//               ),
//             ),
//           if (_isZoomChange == 2)
//             Flexible(
//               child: Text(
//                 location.createdAt.toString().split(' ')[1].split('.')[0],
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
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
//         key: (location) => 'user${location.operatorId}',
//         value: (location) => Marker(
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
//             location.latitude,
//             location.longitude,
//           ),
//           builder: (context) {
//             return builder(location);
//           },
//         ),
//       );
//     }

//     List<Location> userList = [];
//     if (widget.allOperatorId != null)
//       userList.addAll(_locationProvider.currentOperatorLocation);
//     else
//       userList.add(_locationProvider.currentOwnLocation);
//     Map<String, Marker> markers = markersBuilder(userList);
//     _previousLocationNames = markers.keys.toList();
//     await _statefulMapController.addMarkers(markers: markers);
//     if (_firstUser) {
//       _firstUser = false;
//       makeCurrentLocationMapCenter(
//         _locationProvider.makeCurrentLocationToMapCenter(
//             isAdmin: _userProvider.user.role == "admin"),
//       );
//     }
//     if (mounted) setState(() {});
//   }

//   void makeCurrentLocationMapCenter(LatLng point) {
//     if (point != null) _statefulMapController.centerOnPoint(point);
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
//       body: _isLoading
//           ? Progress('Görevler Alınıyor...')
//           : Center(
//               child: SafeArea(
//                 child: Stack(
//                   children: [
//                     FlutterMap(
//                       mapController: _mapController,
//                       options: MapOptions(
//                         center:
//                             _locationProvider.makeCurrentLocationToMapCenter(
//                           isAdmin: _userProvider.user.role == "admin",
//                         ),
//                         zoom: _zoomLevel,
//                         minZoom: 5,
//                         maxZoom: 18.49,
//                       ),
//                       layers: [
//                         new TileLayerOptions(
//                             urlTemplate:
//                                 "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                             subdomains: ['a', 'b', 'c']),
//                         MarkerLayerOptions(
//                           markers: _statefulMapController.markers,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
