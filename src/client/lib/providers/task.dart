import 'dart:async';
import 'dart:convert';

import 'package:business_travel/models/task.dart';
import 'package:business_travel/utilities/global_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utilities/url_creator.dart';

class TaskProvider with ChangeNotifier {
  Task activeTask;
  List<Task> tasks = [];

  Task existActiveTask({int operatorId}) {
    DateTime today = DateTime.now();
    if (operatorId != null) {
      activeTask = tasks.firstWhere(
          (element) =>
              element.operatorId == operatorId &&
              element.startedAt.isBefore(today) &&
              element.finishedAt.isAfter(today),
          orElse: () => null);
    } else {
      activeTask = tasks.firstWhere(
          (element) =>
              element.startedAt.isBefore(today) &&
              element.finishedAt.isAfter(today),
          orElse: () => null);
    }

    return activeTask;
  }

  List<Task> filterTaskByOperator(int operatorId) {
    return tasks.where((element) => element.operatorId == operatorId).toList();
  }

  Future<void> fetchAndSetTasks(
      {String token, int operatorId, int adminId}) async {
    http.Response response;
    try {
      response = await http.get(
        URL.getTask(operatorId: operatorId, adminId: adminId),
        headers: URL.jsonHeader(
          token: token,
        ),
      );
      if (response.statusCode == 200) {
        tasks = [];
        json.decode(response.body)["data"].forEach((e) {
          tasks.add(Task.fromJson(e));
        });
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error fetchAndSetTasks: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> addTask({
    @required int operatorId,
    @required double latitude,
    @required double longitude,
    @required int radius,
    @required DateTime startedAt,
    @required DateTime finishedAt,
    @required String description,
    @required String name,
    @required String token,
  }) async {
    http.Response response;
    try {
      int locationId = await MyProvider.location.sendLocation(
        latitude: latitude,
        longitude: longitude,
        token: token,
      );
      response = await http.post(
        URL.postTask(),
        body: json.encode(
          {
            "data": {
              "adminId": MyProvider.user.user.id,
              "operatorId": operatorId,
              "locationId": locationId,
              "radius": radius,
              "name": name,
              "description": description,
              "isOperatorOnTask": false,
              "startedAt": startedAt.toUtc().toIso8601String(),
              "finishedAt": finishedAt.toUtc().toIso8601String(),
            },
          },
        ),
        headers: URL.jsonHeader(
          token: token,
        ),
      );
      if (response.statusCode == 200) {
        Task task = Task.fromJson(
          json.decode(
            response.body,
          )["data"],
        );
        tasks.insert(0, task);
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error addTask: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> updateTask({
    @required int id,
    @required int operatorId,
    @required double latitude,
    @required double longitude,
    @required int radius,
    @required DateTime startedAt,
    @required DateTime finishedAt,
    @required String description,
    @required String name,
    @required String token,
    bool isOperatorOnTask = false,
  }) async {
    http.Response response;
    try {
      int locationId = await MyProvider.location.sendLocation(
        latitude: latitude,
        longitude: longitude,
        token: token,
      );
      response = await http.put(
        URL.putTask(id: id),
        body: json.encode(
          {
            "data": {
              "adminId": MyProvider.user.user.role == "admin"
                  ? MyProvider.user.user.id
                  : MyProvider.user.admin.id,
              "operatorId": operatorId,
              "locationId": locationId,
              "radius": radius,
              "name": name,
              "description": description,
              "isOperatorOnTask": isOperatorOnTask,
              "startedAt": startedAt.toUtc().toIso8601String(),
              "finishedAt": finishedAt.toUtc().toIso8601String(),
            },
          },
        ),
        headers: URL.jsonHeader(
          token: token,
        ),
      );
      if (response.statusCode == 200) {
        print(response.body);
        Task task = Task.fromJson(
          json.decode(
            response.body,
          )["data"],
        );
        tasks.removeWhere((element) => element.id == task.id);
        tasks.insert(0, task);
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error addTask: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> deleteTask({@required int id, @required String token}) async {
    http.Response response;
    try {
      response = await http.delete(
        URL.deleteTask(id: id),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        tasks.removeWhere((element) => element.id == id);
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error deleteTask: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Task findById(int taskId) {
    Task value = tasks.firstWhere(
      (element) {
        return element.id == taskId;
      },
      orElse: () {
        return null;
      },
    );

    if (value == null) {
      throw Exception('Bu id numarası ile oluşturulan bir görev bulunamadı.');
    }
    return value;
  }

  void addLocalTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void updateLocalTask(Task task) {
    tasks = tasks.map(
      (element) {
        if (element.id == task.id) return task;
        return element;
      },
    ).toList();
    notifyListeners();
  }

  void deleteLocalTask(Task task) {
    tasks.removeWhere(
      (element) => element.id == task.id,
    );
    notifyListeners();
  }

  List<Task> filterTask(String group) {
    DateTime today = DateTime.now();
    switch (group) {
      case "now":
        return tasks
            .where((element) =>
                element.startedAt.isBefore(today) &&
                element.finishedAt.isAfter(today))
            .toList();
      case "future":
        return tasks
            .where((element) => element.startedAt.isAfter(today))
            .toList();
      case "old":
        return tasks
            .where((element) => element.finishedAt.isBefore(today))
            .toList();
      default:
        return tasks;
    }
  }

  List<Map<String, String>> tasksIdAndNameToMap() {
    List<Map<String, String>> drapDownMenuValues = [];
    tasks.forEach((element) {
      drapDownMenuValues
          .add({"display": element.name, "value": element.id.toString()});
    });
    drapDownMenuValues.insert(0, {"value": "0", "display": "hepsi"});
    return drapDownMenuValues;
  }

  String taskIdToName(int id) {
    final task = tasks.firstWhere((element) {
      return element.id == id;
    }, orElse: () => null);
    return task.name;
  }
}
