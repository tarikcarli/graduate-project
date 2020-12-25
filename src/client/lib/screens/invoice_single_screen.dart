import 'package:business_travel/models/invoice.dart';
import 'package:business_travel/providers/invoice.dart';
import 'package:business_travel/providers/location.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/widgets/button_widget.dart';
import 'package:business_travel/widgets/info_line.dart';
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
  @override
  void initState() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);

    mapController = MapController();
    _statefulMapController =
        StatefulMapController(mapController: mapController);
    _statefulMapController.onReady.then((_) async {
      await _statefulMapController.centerOnPoint(
        LatLng(
          widget.invoice.beginLocation.latitude,
          widget.invoice.beginLocation.longitude,
        ),
      );
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
      await _statefulMapController.fitLine("taxiRoute");
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fatura',
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
                if (_userProvider.user.role == "admin") Divider(),
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
                  _taskProvider.findById(widget.invoice.taskId).description,
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
                  (widget.invoice.distance / 1000).toStringAsFixed(2) +
                      " Kilometre",
                ),
                Divider(),
                InformationLine(
                  'Süre:',
                  (widget.invoice.duration / 60000).toStringAsFixed(2) +
                      " Dakika",
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
                                endLocationId: widget.invoice.endLocation.id,
                                cityId: widget.invoice.city.id,
                                price: widget.invoice.price,
                                estimatePrice: widget.invoice.estimatePrice,
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
                                endLocationId: widget.invoice.endLocation.id,
                                cityId: widget.invoice.city.id,
                                price: widget.invoice.price,
                                estimatePrice: widget.invoice.estimatePrice,
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
