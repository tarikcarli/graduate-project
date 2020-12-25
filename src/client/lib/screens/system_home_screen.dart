import 'package:business_travel/models/user.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/system_assign_screen.dart';
import 'package:business_travel/screens/system_user_edit_screen.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:business_travel/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Options {
  exit,
}

class SystemHomeScreen extends StatefulWidget {
  @override
  _SystemHomeScreenState createState() => _SystemHomeScreenState();
}

class _SystemHomeScreenState extends State<SystemHomeScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool firstTime = true;
  UserProvider _userProvider;
  List<User> users = [];
  String _email = "";
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstTime) {
      firstTime = false;
      _userProvider = Provider.of<UserProvider>(context, listen: true);
      _userProvider.addListener(listener);
      getAllUser();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _userProvider.removeListener((listener));
  }

  listener() {
    if (mounted)
      setState(() {
        users = filterUsers(_userProvider.users);
      });
  }

  Future<void> logout() async {
    try {
      await CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "Çıkış işlemi",
        content: "Güvenli bir şekilde çıkış yaptınız.",
        success: true,
      );
      await _userProvider.logout();
    } catch (error) {
      print("system_home_screen logout " + error.toString());
    }
  }

  Future<void> selectProcess(Options value) async {
    if (value == Options.exit) {
      await logout();
    }
  }

  Future<void> getAllUser() async {
    try {
      await _userProvider.getAllUser();
    } catch (error) {
      print("Error getAllUser $error");
    }
    setState(() {
      users = filterUsers(_userProvider.users);
      loading = false;
    });
  }

  void deleteOnTab(user) async {
    final result = await CustomDialog.show(
      ctx: context,
      withCancel: true,
      title: "Kullanıcı Silme",
      content: "Kullanıcıyı silmek istediğinizden emin misiniz?",
    );
    if (result) {
      setState(() {
        loading = true;
      });
      try {
        await _userProvider.deleteOperator(user.id);
      } catch (error) {
        print("Error delete.onTab: $error");
      }
      setState(() {
        loading = false;
      });
    }
  }

  List<User> filterUsers(List<User> users) {
    print(_email);
    return users.where((element) => element.email.startsWith(_email)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sistem Paneli"),
        actions: [
          PopupMenuButton<Options>(
            onSelected: selectProcess,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
              PopupMenuItem<Options>(
                value: Options.exit,
                child: Text("Çıkış"),
              ),
            ],
          ),
        ],
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            )
          : Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Email',
                        ),
                        onChanged: (text) {
                          setState(() {
                            _email = text;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ButtonWidget(
                        buttonName: "Filtrele",
                        onPressed: () {
                          setState(() {
                            users = filterUsers(_userProvider.users);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _userProvider.getAllUser();
                      setState(() {
                        users = filterUsers(_userProvider.users);
                      });
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              URL.getBinaryPhoto(path: user.photo.path),
                            ),
                          ),
                          title: Text('${user.id} ${user.name}'),
                          subtitle: Text(user.email),
                          trailing: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (user.role == "admin")
                                  GestureDetector(
                                    child: Icon(
                                      Icons.add,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) =>
                                              SystemAssignScreen(user),
                                        ),
                                      );
                                    },
                                  ),
                                if (user.role != "admin")
                                  Icon(
                                    Icons.add,
                                    color: Theme.of(context).accentColor,
                                  ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.edit,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => UserEditScreen(user),
                                      ),
                                    );
                                    await _userProvider.getAllUser();
                                    setState(() {
                                      users = filterUsers(_userProvider.users);
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onTap: () => deleteOnTab(user),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
