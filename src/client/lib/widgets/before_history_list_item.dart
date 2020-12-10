import 'package:flutter/material.dart';

import '../models/user.dart';
// import '../screens/location_history_map_screen.dart';

class BeforeHistoryListItem extends StatelessWidget {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  BeforeHistoryListItem({
    @required this.user,
    @required this.duration,
  });
  final User user;
  final int duration;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(
        '${user.name}',
        style: style,
      ),
      subtitle: Text(
        user.email,
        style: style.copyWith(color: Colors.grey, fontSize: 10),
      ),
      onTap: () {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => LocationHistoryMap(
        //       operatorId: user?.id,
        //       duration: duration,
        //     ),
        //   ),
        // );
      },
    );
  }
}
