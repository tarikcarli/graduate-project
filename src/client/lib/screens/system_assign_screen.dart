import 'package:business_travel/models/user.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Options {
  add,
  deleteProfile,
  exit,
  settings,
}

class SystemAssignScreen extends StatefulWidget {
  final User admin;
  SystemAssignScreen(this.admin);
  @override
  _SystemAssignScreenState createState() => _SystemAssignScreenState();
}

class _SystemAssignScreenState extends State<SystemAssignScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool firstTime = true;
  UserProvider _userProvider;
  List<User> users = [];
  List<int> _operatorIds = [];
  String _email = "";
  bool loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstTime) {
      firstTime = false;
      _userProvider = Provider.of<UserProvider>(context, listen: true);
      _userProvider.addListener(listener);
      getAllUser();
      getAdminOperatorIds();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _userProvider.removeListener((listener));
  }

  listener() {
    if (mounted) setState(() {});
  }

  Future<void> getAllUser() async {
    await _userProvider.getAllUser();
    setState(() {
      users = filterUsers(_userProvider.users);
    });
  }

  Future<void> getAdminOperatorIds() async {
    final operatorIds =
        await _userProvider.adminOperatorIds(adminId: widget.admin.id);
    setState(() {
      _operatorIds = operatorIds;
    });
  }

  List<User> filterUsers(List<User> users) {
    return users
        .where((element) =>
            element.email.startsWith(_email) && element.role == "operator")
        .toList();
  }

  Future<void> iconOnTab(User user) async {
    setState(() {
      loading = true;
    });
    try {
      if (_operatorIds.contains(user.id)) {
        await _userProvider.unassignOperator(
            adminId: widget.admin.id, operatorId: user.id);
      } else {
        await _userProvider.assignOperator(
            adminId: widget.admin.id, operatorId: user.id);
      }
      final operatorIds =
          await _userProvider.adminOperatorIds(adminId: widget.admin.id);
      setState(() {
        _operatorIds = operatorIds;
      });
    } catch (error) {
      print("Error iconOnTab: $error");
      CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "Çakışma Oluştu",
        content: "Durum: ${error.toString()}",
      );
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Çalışan Ekle/Çıkar"),
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
                      child: RaisedButton(
                        child: Text("Filtrele", style: style),
                        onPressed: () {
                          setState(() {
                            users = filterUsers(_userProvider.users);
                          });
                        },
                        color: Theme.of(context).primaryColor,
                        textColor: Theme.of(context).accentColor,
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
                      return await _userProvider.getAllUser();
                    },
                    color: Theme.of(context).accentColor,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                URL.getBinaryPhoto(path: user.photo.path)),
                          ),
                          title: Text('${user.id} ${user.name}'),
                          subtitle: Text(user.email),
                          trailing: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: GestureDetector(
                              child: Icon(
                                _operatorIds.contains(user.id)
                                    ? Icons.remove
                                    : Icons.add,
                                color: _operatorIds.contains(user.id)
                                    ? Theme.of(context).errorColor
                                    : Theme.of(context).primaryColor,
                              ),
                              onTap: () => iconOnTab(user),
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
