import 'dart:async';
import 'dart:convert';

import 'package:business_travel/models/task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utilities/url_creator.dart';

class TaskProvider with ChangeNotifier {
  Task activeTask;
  List<Task> tasks = [];

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

  Future<void> addTask(
      {@required int adminId,
      @required int operatorId,
      @required int locationId,
      @required String description,
      @required String name,
      @required String token}) async {
    http.Response response;
    try {
      response = await http.post(
        URL.postTask(),
        body: json.encode(
          {
            "data": {
              "adminId": adminId,
              "operatorId": operatorId,
              "locationId": locationId,
              "name": name,
              "description": description,
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
      print(error);
      throw Exception(
          'Görev ekleme işlemi esnasında bilinmeyen bir hata meydana geldi.\n' +
              'Lütfen internet bağlantınız olduğundan emin olunuz.');
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> updateTask({
    @required int id,
    @required List<int> photoIds,
    @required String comment,
    @required String token,
  }) async {
    http.Response response;
    try {
      response = await http.put(
        URL.putTask(),
        body: json.encode(
          {
            "data": {
              "id": id,
              "comment": comment,
              "photos": photoIds.map((e) => {"id": e}).toList(),
            },
          },
        ),
        headers: URL.jsonHeader(
          token: token,
        ),
      );
      if (response.statusCode == 200) {
        tasks = tasks.map((e) {
          if (e.id == id)
            return Task.fromJson(json.decode(response.body)["data"]);
          return e;
        }).toList();
        notifyListeners();
        return;
      }
    } catch (error) {
      print(error);
      throw Exception(
          'Görev ekleme işlemi esnasında bilinmeyen bir hata meydana geldi.\n' +
              'Lütfen internet bağlantınız olduğundan emin olunuz.');
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}.\n' +
        'Http body:${response.body}.');
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
      print(error);
      throw Exception(
          'Çıkış işlemi esnasında bilinmeyen bir hata meydana geldi.\n' +
              'Lütfen internet bağlantınız olduğundan emin olunuz.');
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
}
