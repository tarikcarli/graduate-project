import 'package:business_travel/models/task.dart';
import 'package:business_travel/providers/location.dart';
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
  String _group = "all";
  List<Task> _tasks = [];
  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _tasksProvider.removeListener(render);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_firstLoading) {
      _firstLoading = false;
      _tasksProvider = Provider.of<TaskProvider>(context, listen: true);
      _tasksProvider.addListener(render);
      getTasks();
    }
  }

  void render() {
    if (mounted)
      setState(() {
        _tasks = _tasksProvider.filterTask(_group);
      });
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
      _tasks = _tasksProvider.filterTask(_group);
      shouldLocationServiceActivate();
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

  void shouldLocationServiceActivate() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    if (_userProvider.user.role == "operator") {
      try {
        if (_tasksProvider.existActiveTask() != null) {
          locationProvider.allowBackgroundTracking(
            token: _userProvider.token,
            adminId: _userProvider?.admin?.id,
            operatorId: _userProvider.user.id,
          );
        } else {
          locationProvider.deniedBackgroundTracking();
        }
        print(_tasksProvider.activeTask);
      } catch (error) {
        print("Error TaskScreens: $error");
      }
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

  void _select(String value) {
    _group = value;
    _tasks = _tasksProvider.filterTask(_group);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Görevler',
          style: style.copyWith(
            color: Theme.of(context).accentColor,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _select,
            initialValue: _group,
            itemBuilder: (BuildContext context) {
              return [
                {"value": "all", "display": "Hepsi"},
                {"value": "now", "display": "Şimdi"},
                {"value": "future", "display": "Gelecek"},
                {"value": "old", "display": "Eski"}
              ].map((Map<String, String> element) {
                return PopupMenuItem<String>(
                  value: element["value"],
                  child: Text(
                    element["display"],
                    style: _group == element["value"]
                        ? style.copyWith(color: Theme.of(context).primaryColor)
                        : style,
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: _loading
          ? ProgressWidget()
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _tasks.length > 0
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              TaskListItem(
                                task: _tasks[i],
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
                        "Görev oluşturmak için çalışanlarınızın olması gerekir.",
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
