import 'package:business_travel/models/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/widgets/info_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:provider/provider.dart';

class SingleTaskScreen extends StatefulWidget {
  final Task task;
  SingleTaskScreen({this.task});

  @override
  _SingleTaskScreenState createState() => _SingleTaskScreenState();
}

class _SingleTaskScreenState extends State<SingleTaskScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  UserProvider _userProvider;
  MapController mapController;
  StatefulMapController _statefulMapController;
  @override
  void initState() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    mapController = MapController();
    _statefulMapController =
        StatefulMapController(mapController: mapController);
    _statefulMapController.onReady.then((_) {
      _statefulMapController.addMarker(
        marker: Marker(
          point: LatLng(
            widget.task.location.latitude,
            widget.task.location.longitude,
          ),
          builder: (context) => Icon(
            Icons.location_on,
            color: Colors.deepOrange,
            size: 25,
          ),
        ),
        name: 'taskLocation',
      );
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Görev',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      center: LatLng(
                        widget.task.location.latitude,
                        widget.task.location.longitude,
                      ),
                      zoom: 7.0,
                      interactive: false,
                    ),
                    layers: [
                      new TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c']),
                      MarkerLayerOptions(
                        markers: _statefulMapController.markers,
                      ),
                      CircleLayerOptions(circles: [
                        CircleMarker(
                          point: LatLng(
                            widget.task.location.latitude,
                            widget.task.location.longitude,
                          ),
                          color: Colors.blue.withOpacity(0.3),
                          borderStrokeWidth: 2.0,
                          borderColor: Colors.blue,
                          useRadiusInMeter: true,
                          radius: widget.task.radius.toDouble() * 1000,
                        )
                      ])
                    ],
                  ),
                ),
                if (_userProvider.user.role == "admin") Divider(),
                if (_userProvider.user.role == "admin")
                  InformationLine(
                    'Çalışan:',
                    '${_userProvider.operatorIdToName(widget.task.operatorId)}',
                  ),
                Divider(),
                InformationLine('Görev:', widget.task.name),
                Divider(),
                InformationLine('Açıklama:', widget.task.description),
                Divider(),
                InformationLine(
                  'Bildirim Mesafesi:',
                  '${widget.task.radius} km',
                ),
                Divider(),
                InformationLine(
                  'Başlangıç Tarihi:',
                  DateFormat.yMd().format(widget.task.startedAt),
                ),
                Divider(),
                InformationLine(
                  'Bitiş Tarihi:',
                  DateFormat.yMd().format(widget.task.finishedAt),
                ),
                Divider(),
                InformationLine(
                  'Oluşturulma Tarihi:',
                  DateFormat.yMd().format(widget.task.createdAt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
