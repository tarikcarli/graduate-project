import 'package:business_travel/models/invoice.dart';
import 'package:business_travel/providers/invoice.dart';
import 'package:business_travel/providers/location.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:business_travel/widgets/button_widget.dart';
import 'package:business_travel/widgets/info_line.dart';
import 'package:business_travel/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:provider/provider.dart';

class SingleInvoiceScreen extends StatefulWidget {
  final Invoice invoice;
  SingleInvoiceScreen({this.invoice});

  @override
  _SingleInvoiceScreenState createState() => _SingleInvoiceScreenState();
}

class _SingleInvoiceScreenState extends State<SingleInvoiceScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  UserProvider _userProvider;
  LocationProvider _locationProvider;
  TaskProvider _taskProvider;
  InvoiceProvider _invoiceProvider;

  MapController mapController;
  StatefulMapController _statefulMapController;
  bool _mapReady = false;
  bool _loading = false;
  @override
  void initState() {
    print("***************************");
    print('invoice_single_screen: ${widget.invoice.toJson()}');
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);

    mapController = MapController();
    _statefulMapController =
        StatefulMapController(mapController: mapController);
    _statefulMapController.onReady.then((_) async {
      _mapReady = true;
      final task = _taskProvider.findById(widget.invoice.taskId);
      await _locationProvider.fetchAndSetLocationHistory(
        operatorId: widget.invoice.operatorId,
        token: _userProvider.token,
        startDate: task.startedAt,
        finishDate: task.finishedAt,
      );
      final lines = _locationProvider.locationsBetweenPoints(
          widget.invoice.beginLocation, widget.invoice.endLocation);
      print(lines.length);
      print(_locationProvider.historyLocation.length);
      await _statefulMapController.addLine(
        name: "taxiRoute",
        points: lines.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        color: Colors.black,
      );
      await addPointToMap();
      setState(() {});
    });
    super.initState();
  }

  addPointToMap() async {
    if (!_mapReady) {
      return;
    }
    await _statefulMapController.addMarker(
      marker: Marker(
        point: LatLng(
          widget.invoice.beginLocation.latitude,
          widget.invoice.beginLocation.longitude,
        ),
        builder: (context) => Icon(
          Icons.location_on,
          color: Colors.deepOrange,
          size: 25,
        ),
      ),
      name: 'beginLocation',
    );
    await _statefulMapController.addMarker(
      marker: Marker(
        point: LatLng(
          widget.invoice.endLocation.latitude,
          widget.invoice.endLocation.longitude,
        ),
        builder: (context) => Icon(
          Icons.location_on,
          color: Colors.deepOrange,
          size: 25,
        ),
      ),
      name: 'endLocation',
    );
    await _statefulMapController.fitLine("taxiRoute");
  }

  onInvoiceTab() async {
    print(widget.invoice.photo.path);
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
                  path: widget.invoice.photo.path,
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
  }

  onEmailTab() async {
    final result = await CustomDialog.show(
      ctx: context,
      withCancel: true,
      title: "Email Gönderme",
      content: "Faturayı emailinize göndermek istiyor musunuz?",
    );
    if (result) {
      setState(() {
        _loading = true;
      });
      try {
        await _invoiceProvider.sendInvoiceMail(
          token: _userProvider.token,
          id: widget.invoice.id,
        );
        await CustomDialog.show(
          ctx: context,
          withCancel: false,
          title: "Email Gönderildi",
          content:
              "Fatura bilgileri sisteme kayıtlı emailinize gönderildi. Lütfen kontrol ediniz.",
          success: true,
        );
      } catch (error) {
        await CustomDialog.show(
          ctx: context,
          withCancel: false,
          title: "Email Gönderilemedi",
          content: "Fatura bilgileri sisteme kayıtlı emailinize gönderilemedi.",
        );
      }
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    addPointToMap();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fatura',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? ProgressWidget()
            : Container(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
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
                            PolylineLayerOptions(
                              polylines: _statefulMapController.lines,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: ButtonWidget(
                              onPressed: onInvoiceTab,
                              buttonName: "Fatura",
                            ),
                          ),
                          if (_userProvider.user.role == "admin")
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                            ),
                          if (_userProvider.user.role == "admin")
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: ButtonWidget(
                                onPressed: onEmailTab,
                                buttonName: "Email",
                              ),
                            ),
                        ],
                      ),
                      if (_userProvider.user.role == "admin")
                        InformationLine(
                          'Operator:',
                          '${_userProvider.operatorIdToName(widget.invoice.operatorId)}',
                        ),
                      Divider(),
                      InformationLine('Görev:',
                          _taskProvider.taskIdToName(widget.invoice.taskId)),
                      Divider(),
                      InformationLine(
                        'Görev Açıklaması:',
                        _taskProvider
                            .findById(widget.invoice.taskId)
                            .description,
                      ),
                      Divider(),
                      InformationLine(
                        'Fatura Tutarı:',
                        widget.invoice.price.toString() + " TL",
                      ),
                      Divider(),
                      InformationLine(
                        'Tahmini Tutarı:',
                        widget.invoice.estimatePrice.toString() + " TL",
                      ),
                      Divider(),
                      InformationLine(
                        'Mesafe:',
                        (widget.invoice.distance / 1000).toStringAsFixed(0) +
                            " Kilometre",
                      ),
                      Divider(),
                      InformationLine(
                        'Süre:',
                        (widget.invoice.endLocation.createdAt.difference(
                                widget.invoice.beginLocation.createdAt))
                            .toString()
                            .split(".")[0],
                      ),
                      Divider(),
                      InformationLine(
                        'Geçerlilik Durumu:',
                        widget.invoice.isValid ? "Geçerli" : "Geçerli değil",
                      ),
                      Divider(),
                      InformationLine(
                        'Kabul Durumu:',
                        widget.invoice.isAccepted == null
                            ? "Bilinmiyor"
                            : widget.invoice.isAccepted
                                ? "Kabul edildi"
                                : "Reddedildi",
                      ),
                      Divider(),
                      InformationLine(
                        'Fatura Tarihi:',
                        DateFormat.yMd().format(widget.invoice.invoicedAt),
                      ),
                      if (_userProvider.user.role == "admin" &&
                          widget.invoice.isAccepted == null)
                        Divider(),
                      if (_userProvider.user.role == "admin" &&
                          widget.invoice.isAccepted == null)
                        Row(
                          children: [
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: ButtonWidget(
                                onPressed: () async {
                                  try {
                                    _invoiceProvider.putInvoice(
                                      id: widget.invoice.id,
                                      adminId: widget.invoice.adminId,
                                      operatorId: widget.invoice.operatorId,
                                      taskId: widget.invoice.taskId,
                                      photo: null,
                                      beginLocationId:
                                          widget.invoice.beginLocation.id,
                                      endLocationId:
                                          widget.invoice.endLocation.id,
                                      cityId: widget.invoice.city.id,
                                      price: widget.invoice.price,
                                      estimatePrice:
                                          widget.invoice.estimatePrice,
                                      distance: widget.invoice.distance,
                                      duration: widget.invoice.duration,
                                      isValid: widget.invoice.isValid,
                                      isAccepted: true,
                                      invoicedAt: widget.invoice.invoicedAt,
                                      token: _userProvider.token,
                                    );
                                    Navigator.of(context).pop();
                                  } catch (error) {
                                    await CustomDialog.show(
                                      ctx: context,
                                      withCancel: false,
                                      title: "Fatura Güncellenemedi",
                                      content: "Durum: " + error.toString(),
                                    );
                                  }
                                },
                                buttonName: "Kabul",
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: ButtonWidget(
                                onPressed: () async {
                                  try {
                                    await _invoiceProvider.putInvoice(
                                      id: widget.invoice.id,
                                      adminId: widget.invoice.adminId,
                                      operatorId: widget.invoice.operatorId,
                                      taskId: widget.invoice.taskId,
                                      photo: null,
                                      beginLocationId:
                                          widget.invoice.beginLocation.id,
                                      endLocationId:
                                          widget.invoice.endLocation.id,
                                      cityId: widget.invoice.city.id,
                                      price: widget.invoice.price,
                                      estimatePrice:
                                          widget.invoice.estimatePrice,
                                      distance: widget.invoice.distance,
                                      duration: widget.invoice.duration,
                                      isValid: widget.invoice.isValid,
                                      isAccepted: false,
                                      invoicedAt: widget.invoice.invoicedAt,
                                      token: _userProvider.token,
                                    );
                                    Navigator.of(context).pop();
                                  } catch (error) {
                                    await CustomDialog.show(
                                      ctx: context,
                                      withCancel: false,
                                      title: "Fatura Güncellenemedi",
                                      content: "Durum: " + error.toString(),
                                    );
                                  }
                                },
                                buttonName: "Red",
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
