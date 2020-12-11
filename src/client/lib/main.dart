import 'package:business_travel/providers/invoice.dart';
import 'package:business_travel/providers/location.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/auth_screen.dart';
import 'package:business_travel/screens/system_home_screen.dart';
import 'package:business_travel/screens/tasks_screen.dart';
import 'package:business_travel/utilities/global_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            lazy: false,
            create: (ctx) {
              MyProvider.invoice = InvoiceProvider();
              return MyProvider.invoice;
            }),
        ChangeNotifierProvider(
            lazy: false,
            create: (ctx) {
              MyProvider.location = LocationProvider();
              return MyProvider.location;
            }),
        ChangeNotifierProvider(
            lazy: false,
            create: (ctx) {
              MyProvider.task = TaskProvider();
              return MyProvider.task;
            }),
        ChangeNotifierProvider(
            lazy: false,
            create: (ctx) {
              MyProvider.user = UserProvider();
              MyProvider.user.checkUserInfo().then((_) {
                setState(() {
                  _loading = false;
                });
              });
              return MyProvider.user;
            }),
      ],
      child: Consumer<UserProvider>(
        builder: (ctx, userProvider, _) {
          return MaterialApp(
            title: 'business travel',
            theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                accentColor: Colors.white,
                focusColor: Colors.yellow),
            home: _loading
                ? Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : userProvider.token == null
                    ? AuthScreen()
                    : userProvider?.user?.role == "system"
                        ? SystemHomeScreen()
                        : TasksScreen(),
          );
        },
      ),
    );
  }
}
