import 'dart:async';

import 'package:business_travel/models/task.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/task_location_map.dart';
import 'package:business_travel/utilities/city_service.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/widgets/progress.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:provider/provider.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  EditTaskScreen(this.task);
  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  int _operatorId;
  int _radius;
  String _name;
  String _description;
  LatLng _coordinate;
  DateTime _startedAt;
  DateTime _finishedAt;
  UserProvider _userProvider;
  TaskProvider _taskProvider;
  TextEditingController _controllerLocation = TextEditingController();
  TextEditingController _controllerStartedAt = TextEditingController();
  TextEditingController _controllerFinishedAt = TextEditingController();
  MapController mapController;
  StatefulMapController _statefulMapController;
  final _form = GlobalKey<FormState>();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _operatorId = widget.task.operatorId;
    _radius = widget.task.radius;
    _name = widget.task.name;
    _description = widget.task.description;
    _coordinate = LatLng(
      widget.task.location.latitude,
      widget.task.location.longitude,
    );
    _startedAt = widget.task.startedAt;
    _finishedAt = widget.task.finishedAt;
    _controllerLocation.text =
        '${_coordinate.latitude.toStringAsFixed(4)},${_coordinate.longitude.toStringAsFixed(4)}';
    _controllerStartedAt.text = _startedAt.toString().split(" ")[0];
    _controllerFinishedAt.text = _finishedAt.toString().split(" ")[0];
    CityService.getCities().then((value) {
      if (mounted) setState(() {});
    });
    mapController = MapController();
    _statefulMapController =
        StatefulMapController(mapController: mapController);
    _statefulMapController.onReady.then((_) {
      _statefulMapController.addMarker(
        marker: Marker(
          point: _coordinate,
          builder: (context) => Icon(
            Icons.location_on,
            color: Colors.deepOrange,
            size: 25,
          ),
        ),
        name: 'taskLocation',
      );
    });
  }

  Future<void> _saveForm() async {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      try {
        setState(() {
          _loading = true;
        });
        await _taskProvider.updateTask(
          id: widget.task.id,
          operatorId: _operatorId,
          radius: _radius,
          latitude: _coordinate.latitude,
          longitude: _coordinate.longitude,
          description: _description,
          name: _name,
          startedAt: _startedAt,
          finishedAt: _finishedAt,
          token: _userProvider.token,
        );
      } catch (error) {
        await CustomDialog.show(
          ctx: context,
          withCancel: false,
          title: "Görev Oluşturma Hatası",
          content: "Durum: ${error.toString()}",
        );
      } finally {
        setState(() {
          _loading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Görev Güncelle',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
      ),
      body: _loading
          ? ProgressWidget()
          : Form(
              key: _form,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            center: _coordinate,
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
                            if (_coordinate != null)
                              CircleLayerOptions(circles: [
                                CircleMarker(
                                  point: LatLng(
                                    _coordinate.latitude,
                                    _coordinate.longitude,
                                  ),
                                  color: Colors.blue.withOpacity(0.3),
                                  borderStrokeWidth: 2.0,
                                  borderColor: Colors.blue,
                                  useRadiusInMeter: true,
                                  radius: _radius.toDouble() * 1000,
                                )
                              ])
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: _controllerLocation,
                              decoration: InputDecoration(
                                labelText: 'Görev Lokasyonu',
                              ),
                              validator: (value) {
                                if (value.isEmpty)
                                  return 'Lütfen Değer giriniz.';
                                return null;
                              },
                              onSaved: (_) {},
                            ),
                          ),
                          Expanded(
                            child: RaisedButton.icon(
                              color: Theme.of(context).primaryColor,
                              textColor: Theme.of(context).accentColor,
                              icon: Icon(Icons.map),
                              label: Text(
                                'Belirle',
                                style: style,
                              ),
                              onPressed: () async {
                                LatLng value =
                                    await Navigator.of(context).push<LatLng>(
                                  MaterialPageRoute(
                                    builder: (context) => TaskLocationMap(),
                                  ),
                                );
                                if (value != null) {
                                  _statefulMapController.centerOnPoint(value);
                                  _statefulMapController.addMarker(
                                    marker: Marker(
                                      point: LatLng(
                                        value.latitude,
                                        value.longitude,
                                      ),
                                      builder: (context) => Icon(
                                        Icons.location_on,
                                        color: Colors.deepOrange,
                                        size: 25,
                                      ),
                                    ),
                                    name: 'taskLocation',
                                  );

                                  _coordinate = value;
                                  _controllerLocation.text =
                                      '${value.latitude.toStringAsFixed(4)},${value.longitude.toStringAsFixed(4)}';
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text("Bildirim Mesafesi:"),
                      Slider(
                        value: _radius.toDouble(),
                        min: 20,
                        max: 200,
                        divisions: 10,
                        label: _radius.toString(),
                        onChanged: (double value) {
                          setState(() {
                            _radius = value.toInt();
                          });
                        },
                      ),
                      DropDownFormField(
                        contentPadding: null,
                        titleText: 'Çalışanlar',
                        hintText: 'Lütfen bir çalışan seçiniz.',
                        value: _operatorId,
                        filled: false,
                        onSaved: (value) {
                          _operatorId = value;
                        },
                        onChanged: (value) {
                          setState(() {
                            _operatorId = value;
                          });
                        },
                        validator: (value) {
                          if (_operatorId == null)
                            return "Görev oluşturmak için çalışan belirlemelisiniz.";
                          return null;
                        },
                        required: true,
                        dataSource: _userProvider.operators
                            .map(
                              (e) => {
                                "display": '${e.name}',
                                "value": e.id,
                              },
                            )
                            .toList(),
                        textField: 'display',
                        valueField: 'value',
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Görev İsmi',
                        ),
                        initialValue: _name,
                        validator: (value) {
                          if (value.isEmpty) return 'Lütfen Değer giriniz.';
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            _name = value;
                          });
                        },
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Görev Açıklaması'),
                        maxLines: 3,
                        initialValue: _description,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value.isEmpty) return 'Lütfen Değer giriniz.';
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                      ),
                      TextFormField(
                        controller: _controllerStartedAt,
                        readOnly: true,
                        decoration:
                            InputDecoration(labelText: 'Başlangıç Tarihi'),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value.isEmpty) return 'Lütfen Değer giriniz.';
                          return null;
                        },
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          _startedAt = date;
                          _controllerStartedAt.text =
                              date.toString().split(" ")[0];
                        },
                      ),
                      TextFormField(
                        controller: _controllerFinishedAt,
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Bitiş Tarihi'),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value.isEmpty) return 'Lütfen Değer giriniz.';
                          return null;
                        },
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          _finishedAt = date;
                          _controllerFinishedAt.text =
                              date.toString().split(" ")[0];
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveForm(),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.save,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
