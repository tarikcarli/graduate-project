import 'package:business_travel/utilities/global_provider.dart';
import 'package:business_travel/widgets/before_two_history_list_item.dart';
import 'package:business_travel/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class BeforeTwoLocationHistoryMap extends StatefulWidget {
  BeforeTwoLocationHistoryMap({
    this.operatorUser,
    this.isAdmin = true,
  });
  final User operatorUser;
  final bool isAdmin;
  @override
  _BeforeTwoLocationHistoryMapState createState() =>
      _BeforeTwoLocationHistoryMapState();
}

class _BeforeTwoLocationHistoryMapState
    extends State<BeforeTwoLocationHistoryMap> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  int duration = 24;

  @override
  Widget build(BuildContext context) {
    final tasks = MyProvider.task.filterTaskByOperator(widget.operatorUser.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Görevler',
          style: style.copyWith(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      drawer: widget.isAdmin ? null : DrawerWidget(),
      body: tasks.length == 0
          ? Center(
              child: Text(
                "Seçilen çalışanın görevi yok!",
                style: style,
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (BuildContext ctx, int index) {
                return BeforeTwoHistoryListItem(
                  task: tasks[index],
                  user: widget.operatorUser,
                );
              }),
    );
  }
}
