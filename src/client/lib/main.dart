import 'package:business_travel/providers/invoice.dart';
import 'package:business_travel/providers/location.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/auth_screen.dart';
import 'package:business_travel/screens/system_home_screen.dart';
import 'package:business_travel/screens/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  @override
  initState() {
    super.initState();
  }

  Future<void> checkUserInfo(UserProvider _userProvider) async {
    try {
      final storage = new FlutterSecureStorage();
      String token = await storage.read(key: 'token');
      if (token != null) {
        _userProvider.token = token;
        int id = int.tryParse(await storage.read(key: 'id'));
        bool runningServer = await _userProvider.checkServerStatus();
        bool validUser = await _userProvider.checkTokenStatus(token: token);
        if (runningServer && validUser) {
          await _userProvider.getMe(id: id);
        }
      }
    } catch (error) {
      print(error);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => InvoiceProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TaskProvider(),
        ),
        ChangeNotifierProvider(create: (ctx) {
          final _userProvider = UserProvider();
          checkUserInfo(_userProvider);
          return _userProvider;
        }),
      ],
      child: Consumer<UserProvider>(
        builder: (ctx, userProvider, _) => MaterialApp(
          title: 'business travel',
          theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              accentColor: Colors.white,
              focusColor: Colors.yellow),
          home: _isLoading
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
        ),
      ),
    );
  }
}
