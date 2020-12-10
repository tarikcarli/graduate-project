import 'package:business_travel/providers/location.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/task_location_map.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/widgets/progress.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

class CreateTask extends StatefulWidget {
  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  int _operatorId;
  String _name;
  String _description;
  LatLng _coordinate;
  UserProvider userProvider;
  TaskProvider taskProvider;
  LocationProvider locationProvider;
  TextEditingController _controller = TextEditingController();
  final _form = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    taskProvider = Provider.of<TaskProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    locationProvider = Provider.of<LocationProvider>(context, listen: false);
  }

  Future<void> _saveForm() async {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      try {
        setState(() {
          _isLoading = true;
        });
        int locationId = await locationProvider.sendLocation(
          latitude: _coordinate.latitude,
          longitude: _coordinate.longitude,
          token: userProvider.token,
        );
        await taskProvider.addTask(
          adminId: userProvider.user.id,
          operatorId: _operatorId,
          locationId: locationId,
          description: _description,
          name: _name,
          token: userProvider.token,
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
          _isLoading = false;
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
          'Görev Oluştur',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
      ),
      body: _isLoading
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
                      DropDownFormField(
                        contentPadding: null,
                        titleText: 'Operatörler',
                        hintText: 'Lütfen bir operatör seçiniz.',
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
                            return "Görev oluşturmak için operatör belirlemelisiniz.";
                          return null;
                        },
                        required: true,
                        dataSource: userProvider.operators
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
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Görev İsmi',
                        ),
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
                      RaisedButton.icon(
                        color: Theme.of(context).primaryColor,
                        textColor: Theme.of(context).accentColor,
                        icon: Icon(Icons.map),
                        label: Text(
                          'Haritadan seç',
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
                            _coordinate = value;
                            _controller.text = 'Enlem: ${value.latitude}, ' +
                                'Boylam: ${value.longitude}';
                          }
                        },
                      ),
                      TextFormField(
                        readOnly: true,
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Görev Lokasyonu',
                        ),
                        validator: (value) {
                          if (value.isEmpty) return 'Lütfen Değer giriniz.';
                          if (value.split(',').length != 2)
                            return 'Lütfen uygun formatta giriniz';
                          return null;
                        },
                        onSaved: (_) {},
                      ),
                      RaisedButton.icon(
                        color: Theme.of(context).primaryColor,
                        textColor: Theme.of(context).accentColor,
                        icon: Icon(Icons.save),
                        label: Text(
                          'Kaydet',
                          style: style,
                        ),
                        onPressed: () => _saveForm(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
