import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/auth_screen.dart';
import 'package:business_travel/screens/invoices_screen.dart';
import 'package:business_travel/screens/location_before_current_map.dart';
import 'package:business_travel/screens/location_before_history_map.dart';
import 'package:business_travel/screens/location_before_two_history_map.dart';
import 'package:business_travel/screens/location_current_map_screen.dart';
import 'package:business_travel/screens/operators_screen.dart';
import 'package:business_travel/screens/system_user_edit_screen.dart';
import 'package:business_travel/screens/system_user_settings_screen.dart';
import 'package:business_travel/screens/tasks_screen.dart';
import 'package:business_travel/utilities/global_provider.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  TextStyle style = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20.0,
  );
  UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: CircleAvatar(
              backgroundImage: AssetImage(
                "assets/images/blue_map.jpg",
              ),
              radius: MediaQuery.of(context).size.width * 0.2,
              backgroundColor: Colors.transparent,
            ),
          ),
          if (_userProvider?.user?.role == "admin")
            ListTile(
              leading: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                "Çalışanlar",
                style: style,
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => OperatorsScreen(),
                  ),
                );
              },
            ),
          ListTile(
            leading: Icon(
              Icons.assignment,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Görevler",
              style: style,
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => TasksScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.receipt,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Faturalar",
              style: style,
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => InvoicesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Canlı Konum",
              style: style,
            ),
            onTap: () {
              if (_userProvider?.user?.role == "admin") {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => BeforeLocationCurrentMap(
                      allOperator: _userProvider.operators,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => LocationCurrentMap(
                      operatorId: _userProvider.user.id,
                      isAdmin: false,
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.location_history,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Konum Geçmişi",
              style: style,
            ),
            onTap: () {
              if (_userProvider?.user?.role == "admin") {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => BeforeLocationHistoryMap(
                      allOperator: _userProvider.operators,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => BeforeTwoLocationHistoryMap(
                      operatorUser: _userProvider.user,
                      isAdmin: false,
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Ayarlar",
              style: style,
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => UserSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.perm_identity,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Profil",
              style: style,
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => UserEditScreen(_userProvider.user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Çıkış",
              style: style,
            ),
            onTap: () async {
              try {
                await CustomDialog.show(
                  ctx: context,
                  withCancel: false,
                  title: "Çıkış işlemi",
                  content: "Güvenli bir şekilde çıkış yaptınız.",
                  success: true,
                );
                if (_userProvider.user.role == "operator") {
                  MyProvider.location.deniedBackgroundTracking();
                }
                await _userProvider.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => AuthScreen(),
                  ),
                );
              } catch (error) {
                print("Error DrawerWidget.exit: " + error.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}
