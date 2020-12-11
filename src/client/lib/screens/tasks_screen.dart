import 'package:business_travel/models/task.dart';
import 'package:business_travel/providers/task.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/task_create_screen.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/widgets/drawer_widget.dart';
import 'package:business_travel/widgets/progress.dart';
import 'package:business_travel/widgets/task_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TaskProvider _tasksProvider;
  UserProvider _userProvider;
  bool _loading = true;
  bool _firstLoading = true;
  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _tasksProvider.removeListener(changeTaskToState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstLoading) {
      _firstLoading = false;
      _tasksProvider = Provider.of<TaskProvider>(context, listen: true);
      _tasksProvider.addListener(changeTaskToState);
      getTasks();
    }
  }

  void changeTaskToState() {
    if (mounted) setState(() {});
  }

  Future<void> getTasks() async {
    try {
      if (_userProvider.user.role == "admin")
        await _tasksProvider.fetchAndSetTasks(
          token: _userProvider.token,
          adminId: _userProvider.user.id,
        );
      else
        await _tasksProvider.fetchAndSetTasks(
          token: _userProvider.token,
          operatorId: _userProvider.user.id,
        );
    } catch (error) {
      await CustomDialog.show(
        ctx: context,
        withCancel: false,
        title: "Görevler Alınamadı",
        content: "Durum: ${error.toString()}",
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> deleteTask(Task task, token) async {
    final result = await CustomDialog.show(
      ctx: context,
      withCancel: true,
      title: "Görev Silme",
      content: "Görevi silmek istediğinizden emin misiniz ?",
    );
    if (result) {
      try {
        await _tasksProvider.deleteTask(
          id: task.id,
          token: token,
        );
      } catch (error) {
        await CustomDialog.show(
          ctx: context,
          withCancel: false,
          title: "Görev Silme İşlemi Hatası",
          content: "Durum: ${error.toString()}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasksProvider?.tasks;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Görevler',
          style: style.copyWith(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      drawer: DrawerWidget(),
      body: _loading
          ? ProgressWidget()
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tasks.length > 0
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              TaskListItem(
                                task: _tasksProvider.tasks[i],
                                deleteTask: deleteTask,
                                user: _userProvider.user,
                                token: _userProvider.token,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: Center(
                          child: Text(
                            'Hiç Göreviniz Yok!',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
              ],
            ),
      floatingActionButton: _userProvider.user.role == "admin"
          ? FloatingActionButton(
              onPressed: () async {
                if (_userProvider.operators.length == 0) {
                  await CustomDialog.show(
                    ctx: context,
                    withCancel: false,
                    title: "Görev Oluşturamazsınız",
                    content:
                        "Görev oluşturmak için operatörünüzün olması gerekir.",
                  );
                } else {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateTask(),
                    ),
                  );
                  setState(() {});
                }
              },
              child: Icon(
                Icons.add,
                color: Theme.of(context).accentColor,
              ),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }
}
