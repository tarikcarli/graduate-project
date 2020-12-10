import 'package:business_travel/models/user.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final void Function(DismissDirection direction, Task task) onDismiss;
  final User user;
  TaskListItem({this.task, this.onDismiss, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dismissible(
        key: ValueKey(task.id),
        background: Container(
          color: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          if (user.role == "admin")
            return CustomDialog.show(
              ctx: context,
              withCancel: true,
              title: "Emin misiniz?",
              content: "Görevi silmek istediğinizden emin misiniz?\n" +
                  "Bu işlem geri alınamaz.",
            );
          else
            return CustomDialog.show(
              ctx: context,
              withCancel: false,
              title: "Yetersiz Yetki",
              content: 'Görevi silebilmek için yönetici olmalısınız.',
            );
        },
        onDismissed: (direction) {
          onDismiss(direction, task);
        },
        child: ListTile(
          title: Text(task.name),
          subtitle: Text(task.description),
        ),
      ),
    );
  }
}
