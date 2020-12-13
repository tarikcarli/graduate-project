import 'package:business_travel/models/user.dart';
import 'package:business_travel/screens/task_edit_screen.dart';
import 'package:business_travel/screens/task_single_screen.dart';
import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskListItem extends StatelessWidget {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final Task task;
  final void Function(Task task, String token) deleteTask;
  final User user;
  final String token;
  TaskListItem({this.task, this.deleteTask, this.user, this.token});

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
      trailing: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Row(
          children: [
            if (user.role == "admin")
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => EditTaskScreen(
                          task,
                        ),
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: IconButton(
                icon: Icon(
                  Icons.details,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => SingleTaskScreen(task: task),
                    ),
                  );
                },
              ),
            ),
            if (user.role == "admin")
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                  onPressed: () => deleteTask(task, token),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
