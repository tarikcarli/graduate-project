import 'package:business_travel/models/task.dart';
import 'package:business_travel/models/user.dart';
import 'package:business_travel/screens/location_history_map_screen.dart';
import 'package:flutter/material.dart';

class BeforeTwoHistoryListItem extends StatelessWidget {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  BeforeTwoHistoryListItem({
    @required this.user,
    @required this.task,
  });
  final User user;
  final Task task;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.name,
        style: style.copyWith(fontWeight: FontWeight.bold),
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        task.description,
        style: style.copyWith(fontSize: 13),
        maxLines: 2,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LocationHistoryMap(
              user: user,
              task: task,
            ),
          ),
        );
      },
    );
  }
}
