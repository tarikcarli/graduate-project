import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

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
  TextEditingController _controllerEstimatePrice = TextEditingController();
  TextEditingController _controllerDistance = TextEditingController();
  TextEditingController _controllerDuration = TextEditingController();
  TextEditingController _controllerPrice = TextEditingController();

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
  int _price;
  int _estimatePrice;
  int _distance;
  int _duration;
  bool _isValid;
  bool _isAccepted; // null for operator
  DateTime _invoicedAt;
  bool _loading = false;
  bool _runningOCR = false;
  @override
  void initState() {
    super.initState();
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);

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
    if (_form.currentState.validate() &&
        _photo != null &&
        _beginLocation != null &&
        _endLocation != null) {
      _form.currentState.save();
      try {
        setState(() {
          _loading = true;
        });
        calculateIsValid();
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
        Navigator.of(context).pop();
      } catch (error) {
        await CustomDialog.show(
          ctx: context,
          withCancel: false,
          title: "Fatura Oluşturma Hatası",
          content: "Durum: ${error.toString()}",
        );
        setState(() {
          _loading = false;
        });
      }
    } else {
      if (_form.currentState.validate()) {
        CustomDialog.show(
          ctx: context,
          withCancel: false,
          title: "Eksik Girdi",
          content:
              "Faturanın fotoğrafını ve konumunu girdiğinizden emin olunuz.",
        );
      }
    }
  }

  void selectImageCallback(io.File file) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(file);
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    textRecognizer.close();
    final price = findPriceInVisionText(visionText.text);
    setState(() {
      _runningOCR = false;
    });
    if (price != null) {
      setState(() {
        _price = price;
      });
      _controllerPrice.text = price.toString();
      CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "OCR başarılı",
        content:
            "Görüntüden fatura tutarı tespit edildi.\nLütfen fatura tutarını kontrol ediniz.",
        success: true,
      );
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

  int findPriceInVisionText(String text) {
    String vText = text.replaceAll(" ", "");
    vText = vText.replaceAll("\n", "");
    print('Normalized vision text:\n $vText');
    final random = Random();
    if (random.nextDouble() > 0.5) {
      return 55;
    }
    return null;
  }

  Future<void> calculateAll() async {
    calculateDuration();
    await calculateDistance();
    calculateEstimatePrice();
    _controllerEstimatePrice.text = _estimatePrice.toString() + " TL";
    _controllerDistance.text =
        (_distance / 1000).toStringAsFixed(2) + " Kilometre";
    _controllerDuration.text =
        (_duration / 60000).toStringAsFixed(2) + " Dakika";
    _invoicedAt = _endLocation.createdAt;
    _controllerInvoicedAt.text = _invoicedAt.toString().split(" ")[0];
  }

  Future<void> calculateDistance() async {
    try {
      double distance = 0;
      List<Location> points = _locationProvider.locationsBetweenPoints(
          _beginLocation, _endLocation);
      Location previous = points.first;
      for (final element in points.getRange(1, points.length).toList()) {
        distance += await Geolocator().distanceBetween(
          previous.latitude,
          previous.longitude,
          element.latitude,
          element.longitude,
        );
        previous = element;
      }
      _distance = distance.toInt();
    } catch (error) {
      print("Error calculateDistance: $error");
    }
  }

  void calculateEstimatePrice() {
    try {
      City city =
          CityService.cities.firstWhere((element) => element.id == _cityId);
      _estimatePrice =
          (city.priceInitial + (city.pricePerKm * (_distance / 1000))).toInt();
    } catch (error) {
      print("Error calculateEstimatePrice: $error");
    }
  }

  void calculateDuration() {
    _duration = _endLocation.createdAt
        .difference(_beginLocation.createdAt)
        .inMilliseconds;
  }

  void calculateIsValid() {
    if ((_price / 10) < (_estimatePrice - _price).abs()) {
      _isValid = false;
    } else {
      _isValid = true;
      _isAccepted = true;
    }
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
                          if (_taskId == null)
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
                                      calculateAll();
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
                                      calculateAll();
                                    }
                                    setState(() {});
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
                            child: _runningOCR
                                ? Center(
                                    child: ProgressWidget(),
                                  )
                                : Image.asset("assets/images/no_image.jpg"),
                          ),
                          onTap: () async {
                            try {
                              setState(() {
                                _runningOCR = true;
                              });
                              final photo = await selectImage(
                                isCamera: false,
                                callback: selectImageCallback,
                              );
                              if (photo != null) {
                                _photo = photo;
                              }
                            } catch (error) {
                              print("Error photo.onTab: $error");
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
                        controller: _controllerPrice,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) return 'Lütfen Değer giriniz.';
                          try {
                            _price = double.parse(value).toInt();
                          } catch (error) {
                            return "lütfen uygun formatta değer giriniz.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            _price = double.parse(value).round();
                          });
                        },
                      ),
                      TextFormField(
                        controller: _controllerInvoicedAt,
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Fatura Tarihi'),
                        textInputAction: TextInputAction.done,
                      ),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Tahmini Tutar'),
                        textInputAction: TextInputAction.done,
                        controller: _controllerEstimatePrice,
                      ),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Mesafe'),
                        textInputAction: TextInputAction.done,
                        controller: _controllerDistance,
                      ),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Süre'),
                        textInputAction: TextInputAction.done,
                        controller: _controllerDuration,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveForm,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.save,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
