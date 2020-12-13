import 'package:business_travel/models/user.dart';
import 'package:business_travel/screens/location_before_two_history_map.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:flutter/material.dart';

class BeforeHistoryListItem extends StatelessWidget {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  BeforeHistoryListItem({
    @required this.user,
  });
  final User user;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          URL.getBinaryPhoto(path: user.photo.path),
        ),
      ),
      title: Text(
        '${user.name}',
        style: style,
      ),
      subtitle: Text(
        user.email,
        style: style.copyWith(color: Colors.grey, fontSize: 10),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BeforeTwoLocationHistoryMap(
              operatorUser: user,
            ),
          ),
        );
      },
    );
  }
}
