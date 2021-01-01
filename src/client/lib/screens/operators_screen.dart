import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/operator_single_screen.dart';
import 'package:business_travel/widgets/drawer_widget.dart';
import 'package:business_travel/widgets/user_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OperatorsScreen extends StatefulWidget {
  @override
  _OperatorsScreenState createState() => _OperatorsScreenState();
}

class _OperatorsScreenState extends State<OperatorsScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  UserProvider _userProvider;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(
      context,
      listen: true,
    );
    _userProvider.addListener(render);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _userProvider.removeListener(render);
    super.dispose();
  }

  void render() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final operators = _userProvider.operators;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Çalışanlar',
          style: style.copyWith(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              operators.length > 0
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: operators.length,
                        itemBuilder: (ctx, i) => Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SingleOperatorScreen(
                                          user: operators[i]);
                                    },
                                  ),
                                );
                              },
                              child: UserListItem(
                                user: operators[i],
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Text(
                          'Hiç Çalışanınız Yok!',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
