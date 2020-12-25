import 'package:business_travel/models/user.dart';
import 'package:business_travel/widgets/before_current_list_item.dart';
import 'package:business_travel/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

class BeforeLocationCurrentMap extends StatelessWidget {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  BeforeLocationCurrentMap({
    @required this.allOperator,
  });
  final List<User> allOperator;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Çalışanlar',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
      ),
      drawer: DrawerWidget(),
      body: allOperator.length == 0
          ? Center(
              child: Text(
                "Hiç Çalışanınız yok!",
                style: style,
              ),
            )
          : ListView.builder(
              itemCount: allOperator.length,
              itemBuilder: (BuildContext ctx, int index) {
                return BeforeCurrentListItem(
                  user: allOperator[index],
                );
              }),
    );
  }
}
