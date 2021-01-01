import 'package:business_travel/screens/location_current_map_screen.dart';
import 'package:business_travel/utilities/global_provider.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
// import '../screens/location_current_map_screen.dart';

class BeforeCurrentListItem extends StatelessWidget {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  BeforeCurrentListItem({
    @required this.user,
  });
  final User user;
  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      tileColor: MyProvider.task.existActiveTask(operatorId: user.id) == null
          ? Colors.red[200]
          : Colors.green[200],
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            URL.getBinaryPhoto(path: user.photo.path),
          ),
        ),
        title: Text(
          user.name,
          style: style,
        ),
        subtitle: Text(
          user.email,
          style: style.copyWith(color: Colors.grey, fontSize: 10),
        ),
        onTap: () {
          if (MyProvider.task.existActiveTask(operatorId: user.id) == null) {
            CustomDialog.show(
              ctx: context,
              withCancel: false,
              title: "Hata",
              content:
                  "Aktif görevi olmayan çalışanların canlı konum verisini görüntüleyemezsiniz.",
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LocationCurrentMap(
                  operatorId: user.id,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
