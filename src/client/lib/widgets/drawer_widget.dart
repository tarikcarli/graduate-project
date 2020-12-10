import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/system_user_edit_screen.dart';
import 'package:business_travel/screens/system_user_settings_screen.dart';
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
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Operatorler",
              style: style,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.assignment,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Tasks",
              style: style,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.receipt,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Invoices",
              style: style,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Live Location",
              style: style,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.location_history,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "History Location",
              style: style,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              "Settings",
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
              "Profile",
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
              "Exit",
              style: style,
            ),
            onTap: () async {
              await _userProvider.logout();
            },
          ),
        ],
      ),
    );
  }
}
