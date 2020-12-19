import 'package:business_travel/providers/user.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/widgets/drawer_widget.dart';
import 'package:business_travel/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../widgets/button_widget.dart';

class UserSettingsScreen extends StatefulWidget {
  static const String NOTIFICATION = "letBackgorundNotification";
  static const String LOCATION = "_letBackgorundLocation";
  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  UserProvider _userProvider;
  bool _letBackgorundNotification;
  bool _letBackgorundLocation;
  bool loading = true;
  final storage = new FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    readUserSettings();
  }

  Future<void> readUserSettings() async {
    final letBackgorundNotification =
        await storage.read(key: UserSettingsScreen.NOTIFICATION);
    final letBackgorundLocation =
        await storage.read(key: UserSettingsScreen.LOCATION);
    setState(() {
      _letBackgorundNotification = letBackgorundNotification == "true" ||
          letBackgorundNotification == null;
      _letBackgorundLocation =
          letBackgorundLocation == "true" || letBackgorundLocation == null;
      loading = false;
    });
  }

  Future<void> writeUserSettings() async {
    try {
      await storage.write(
        key: UserSettingsScreen.NOTIFICATION,
        value: _letBackgorundNotification ? "true" : "false",
      );
      await storage.write(
        key: UserSettingsScreen.LOCATION,
        value: _letBackgorundLocation ? "true" : "false",
      );
      await CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "Kullanıcı Tercihleri",
        content: "Durum: Tercihleriniz kaydedildi.",
        success: true,
      );
    } catch (error) {
      await CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "Hata Oluştu",
        content: "Durum: ${error.toString()}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 18.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kullanıcı Ayarları',
          style: style.copyWith(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      drawer: DrawerWidget(),
      body: SafeArea(
        child: loading
            ? ProgressWidget(text: "Ayarlar alınıyor...")
            : Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (_userProvider.user.role == "operator")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            flex: 4,
                            child: Text(
                              "Uygulama kapalıyken konum verilerine ulaşabilir :",
                              style: style,
                            ),
                          ),
                          Flexible(
                            child: Switch(
                              value: _letBackgorundLocation,
                              onChanged: (value) {
                                setState(() {
                                  _letBackgorundLocation = value;
                                });
                              },
                              activeTrackColor: Theme.of(context).primaryColor,
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          flex: 4,
                          child: Text(
                            "Uygulama kapalıyken bildirim gönderebilir :",
                            style: style,
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Switch(
                            value: _letBackgorundNotification,
                            onChanged: (value) {
                              setState(() {
                                _letBackgorundNotification = value;
                              });
                            },
                            activeTrackColor: Theme.of(context).primaryColor,
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ButtonWidget(
                        onPressed: writeUserSettings,
                        buttonName: "Kaydet",
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
