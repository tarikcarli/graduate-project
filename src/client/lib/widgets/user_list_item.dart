import 'package:business_travel/utilities/url_creator.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class UserListItem extends StatelessWidget {
  final User user;
  UserListItem({this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          URL.getBinaryPhoto(path: user.photo.path),
        ),
      ),
      title: Text('${user.name}'),
      subtitle: Text(user.email),
    );
  }
}
