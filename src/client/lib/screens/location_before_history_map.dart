import 'package:business_travel/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/before_history_list_item.dart';

class BeforeLocationHistoryMap extends StatefulWidget {
  BeforeLocationHistoryMap({
    this.allOperator,
  });
  final List<User> allOperator;

  @override
  _BeforeLocationHistoryMapState createState() =>
      _BeforeLocationHistoryMapState();
}

class _BeforeLocationHistoryMapState extends State<BeforeLocationHistoryMap> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
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
      body: widget.allOperator.length == 0
          ? Center(
              child: Text(
                "Hiç Çalışanınız yok!",
                style: style,
              ),
            )
          : ListView.builder(
              itemCount: widget.allOperator.length,
              itemBuilder: (BuildContext ctx, int index) {
                return BeforeHistoryListItem(
                  user: widget.allOperator[index],
                );
              }),
    );
  }
}
