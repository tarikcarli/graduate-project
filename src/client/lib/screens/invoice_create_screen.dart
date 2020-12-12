import 'dart:async';
import 'dart:io' as io;

import 'package:business_travel/models/city.dart';
import 'package:business_travel/models/location.dart';
import 'package:business_travel/providers/invoice.dart';
import 'package:business_travel/providers/location.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/invoice_map_screen.dart';
import 'package:business_travel/utilities/city_service.dart';
import 'package:business_travel/utilities/image_convert.dart';
import 'package:business_travel/utilities/ready_image.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/widgets/progress.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:provider/provider.dart';

class CreateInvoiceScreen extends StatefulWidget {
  @override
  _CreateInvoiceScreenState createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final TextRecognizer textRecognizer =
      FirebaseVision.instance.textRecognizer();
  UserProvider _userProvider;
  TaskProvider _taskProvider;
  InvoiceProvider _invoiceProvider;
  LocationProvider _locationProvider;

  TextEditingController _controllerInvoicedAt = TextEditingController();
  MapController mapController;
  StatefulMapController _statefulMapController;
  final _form = GlobalKey<FormState>();
  int _adminId;
  int _operatorId;
  int _taskId;
  String _photo;
  Location _beginLocation;
  Location _endLocation;
  int _cityId;
  double _price;
  double _estimatePrice;
  double _distance;
  double _duration;
  bool _isValid;
  bool _isAccepted; // null for operator
  DateTime _invoicedAt;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);

    CityService.getCities().then((value) {
      if (mounted) setState(() {});
    });
    mapController = MapController();
    _statefulMapController =
        StatefulMapController(mapController: mapController);
    _adminId = _userProvider.admin.id;
    _operatorId = _userProvider.user.id;
  }

  Future<void> _saveForm() async {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      try {
        setState(() {
          _loading = true;
        });
        await _invoiceProvider.addInvoice(
          adminId: _adminId,
          operatorId: _operatorId,
          taskId: _taskId,
          photo: _photo,
          beginLocationId: _beginLocation.id,
          endLocationId: _endLocation.id,
          cityId: _cityId,
          price: _price,
          estimatePrice: _estimatePrice,
          distance: _distance,
          duration: _duration,
          isValid: _isValid,
          isAccepted: _isAccepted,
          invoicedAt: _invoicedAt,
          token: _userProvider.token,
        );
      } catch (error) {
        await CustomDialog.show(
          ctx: context,
          withCancel: false,
          title: "Fatura Oluşturma Hatası",
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

  void selectImageCallback(io.File file) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(file);
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    print("VISION TEXT:\n${visionText.text}");
    final price = findPriceInVisionText(visionText.text);
    if (price != null) {
      setState(() {
        _price = price;
      });
    } else {
      CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "OCR başarısız",
        content:
            "Görüntüden fatura tutarı tespit edilemedi.\nLütfen kendiniz girisiz",
      );
    }
  }

  double findPriceInVisionText(String text) {
    return null;
  }

  Future<void> calculateDistance() async {
    try {
      double distance = 0;
      List<Location> points = _locationProvider.locationsBetweenPoints(
          _beginLocation, _endLocation);
      Location previous = points.first;
      for (final element in points.getRange(0, points.length - 1).toList()) {
        distance += await Geolocator().distanceBetween(
          previous.latitude,
          previous.longitude,
          element.latitude,
          element.longitude,
        );
      }
      _distance = distance;
    } catch (error) {
      print("Error calculateDistance: $error");
    }
  }

  void calculateIsValid() {
    if ((_price / 10) < (_estimatePrice - _price).abs()) {
      _isValid = false;
    } else {
      _isValid = true;
      _isAccepted = true;
    }
  }

  void calculateEstimatePrice() {
    try {
      City city =
          CityService.cities.firstWhere((element) => element.id == _cityId);
      _estimatePrice =
          city.priceInitial + (city.pricePerKm * (_distance / 1000));
    } catch (error) {
      print("Error calculateEstimatePrice: $error");
    }
  }

  void calculateDuration() {
    _duration = _beginLocation.createdAt
        .difference(_endLocation.createdAt)
        .inMicroseconds
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fatura Oluştur',
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
                            center: LatLng(40.774173, 29.573892),
                            zoom: 8.0,
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
                          ],
                        ),
                      ),
                      DropDownFormField(
                        contentPadding: null,
                        titleText: 'Görevler',
                        hintText: 'Lütfen bir görev seçiniz.',
                        value: _taskId,
                        filled: false,
                        onSaved: (value) {
                          _taskId = value;
                        },
                        onChanged: (value) {
                          final task = _taskProvider.findById(value);
                          _statefulMapController.centerOnPoint(LatLng(
                            task.location.latitude,
                            task.location.longitude,
                          ));
                          setState(() {
                            _taskId = value;
                          });
                        },
                        validator: (value) {
                          if (_operatorId == null)
                            return "Fatura oluşturmak için görev belirlemelisiniz.";
                          return null;
                        },
                        required: true,
                        dataSource: _taskProvider
                            .tasksIdAndNameToMap()
                            .skip(1)
                            .map(
                              (e) => {
                                "display": e["display"],
                                "value": int.tryParse(e["value"]),
                              },
                            )
                            .toList(),
                        textField: 'display',
                        valueField: 'value',
                      ),
                      DropDownFormField(
                        contentPadding: null,
                        titleText: 'Şehirler',
                        hintText: 'Lütfen görevin şehrini seçiniz.',
                        value: _cityId,
                        filled: false,
                        onSaved: (value) {
                          _cityId = value;
                        },
                        onChanged: (value) {
                          setState(() {
                            _cityId = value;
                          });
                        },
                        validator: (value) {
                          if (_cityId == null)
                            return "Görev oluşturmak için Şehir belirlemelisiniz.";
                          return null;
                        },
                        required: true,
                        dataSource: CityService.cities
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
                      if (_taskId != null && _cityId != null)
                        SizedBox(
                          height: 8,
                        ),
                      if (_taskId != null && _cityId != null)
                        Row(
                          children: [
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: RaisedButton.icon(
                                color: Theme.of(context).primaryColor,
                                textColor: Theme.of(context).accentColor,
                                icon: Icon(Icons.map),
                                label: Text(
                                  'Başlangıç',
                                  style: style,
                                ),
                                onPressed: () async {
                                  final task = _taskProvider.findById(_taskId);
                                  Location value = await Navigator.of(context)
                                      .push<Location>(
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceMapScreen(
                                        operatorId: _operatorId,
                                        taskLocation: task.location,
                                        taskStartDate: task.startedAt,
                                        taskEndDate: task.finishedAt,
                                      ),
                                    ),
                                  );
                                  if (value != null) {
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
                                      name: 'beginLocation',
                                    );
                                    _beginLocation = value;
                                    if (_beginLocation != null &&
                                        _endLocation != null) {
                                      calculateDistance();
                                      calculateEstimatePrice();
                                      calculateDuration();
                                    }
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: RaisedButton.icon(
                                color: Theme.of(context).primaryColor,
                                textColor: Theme.of(context).accentColor,
                                icon: Icon(Icons.map),
                                label: Text(
                                  'Bitiş',
                                  style: style,
                                ),
                                onPressed: () async {
                                  final task = _taskProvider.findById(_taskId);
                                  Location value = await Navigator.of(context)
                                      .push<Location>(
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceMapScreen(
                                        operatorId: _operatorId,
                                        taskLocation: task.location,
                                        taskStartDate: task.startedAt,
                                        taskEndDate: task.finishedAt,
                                      ),
                                    ),
                                  );
                                  if (value != null) {
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
                                      name: 'endLocation',
                                    );
                                    _endLocation = value;
                                    if (_beginLocation != null &&
                                        _endLocation != null) {
                                      calculateDistance();
                                      calculateEstimatePrice();
                                      calculateDuration();
                                    }
                                    setState(() {});
                                    print(_estimatePrice);
                                    print(_distance);
                                    print(_duration);
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 8,
                      ),
                      if (_photo != null)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Image.memory(
                            ImageConvert.dataFromBase64String(_photo),
                          ),
                        ),
                      if (_photo == null)
                        GestureDetector(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: Image.asset("assets/images/no_image.jpg"),
                          ),
                          onTap: () async {
                            final photo = await selectImage(
                              isCamera: false,
                              callback: selectImageCallback,
                            );
                            if (photo != null) {
                              setState(() {
                                _photo = photo;
                              });
                            }
                          },
                        ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Tutar',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _price.toString() == "null"
                            ? ""
                            : _price.toString(),
                        validator: (value) {
                          if (value.isEmpty) return 'Lütfen Değer giriniz.';
                          try {
                            _price = double.parse(value);
                          } catch (error) {
                            return "lütfen uygun formatta değer giriniz.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            _price = double.parse(value);
                          });
                        },
                      ),
                      TextFormField(
                        controller: _controllerInvoicedAt,
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Fatura Tarihi'),
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
                          if (date != null) {
                            _invoicedAt = date;
                            _controllerInvoicedAt.text =
                                date.toString().split(" ")[0];
                          }
                        },
                      ),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Tahmini Tutar'),
                        textInputAction: TextInputAction.done,
                        initialValue: _estimatePrice.toString() == "null"
                            ? ""
                            : _estimatePrice.toString(),
                        validator: (value) {
                          if (value.isEmpty) return 'Lütfen Değer giriniz.';
                          try {
                            _estimatePrice = double.parse(value);
                          } catch (error) {
                            return "lütfen uygun formatta değer giriniz.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            _estimatePrice = double.tryParse(value);
                          });
                        },
                      ),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Mesafe'),
                        textInputAction: TextInputAction.done,
                        initialValue: _distance.toString() == "null"
                            ? ""
                            : (_distance / 1000).toString() + " Kilometre",
                      ),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Süre'),
                        textInputAction: TextInputAction.done,
                        initialValue: _duration.toString() == "null"
                            ? ""
                            : (_duration / 60000).toString() + " Dakika",
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
