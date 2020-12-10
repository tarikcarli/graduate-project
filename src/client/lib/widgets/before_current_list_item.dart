import 'package:flutter/material.dart';

import '../models/user.dart';
// import '../screens/location_current_map_screen.dart';

class BeforeCurrentListItem extends StatelessWidget {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  BeforeCurrentListItem({
    @required this.user,
    @required this.allUser,
  });
  final User user;
  final List<User> allUser;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(
        user.name,
        style: style,
      ),
      subtitle: Text(
        user.email,
        style: style.copyWith(color: Colors.grey, fontSize: 10),
      ),
      onTap: () {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => LocationCurrentMap(
        //       allOperatorId: user.role == "admin" ? null : [user.id],
        //     ),
        //   ),
        // );
      },
    );
  }
}
