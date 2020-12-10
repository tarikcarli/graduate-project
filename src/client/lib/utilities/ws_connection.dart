import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

// import '../models/location.dart';
// import '../models/task.dart';
import '../providers/location.dart';
import '../providers/task.dart';
import '../providers/user.dart';
// import '../helpers/notification.dart';

class Type {
  static const INTRODUCTION = "INTRODUCTION";
  static const VARIFIED = "VARIFIED";
  static const UNAUTHORIZATED = "UNAUTHORIZATED";
  static const TASK_CREATED = "TASK_CREATED";
  static const TASK_UPDATED = "TASK_UPDATED";
  static const TASK_DELETED = "TASK_DELETED";
  static const OPERATOR_LOCATION_CREATED = "OPERATOR_LOCATION_CREATED";
  static const TASK_CREATED_NOTIFICATION = "TASK_CREATED_NOTIFICATION";
  static const TASK_UPDATED_NOTIFICATION = "TASK_UPDATED_NOTIFICATION";
}

class WebSocket {
  WebSocket({
    @required this.url,
    @required this.taskProvider,
    @required this.locationProvider,
    @required this.userProvider,
  });
  final TaskProvider taskProvider;
  final LocationProvider locationProvider;
  final UserProvider userProvider;
  final String url;
  IOWebSocketChannel _channel;

  void open() {
    _channel = IOWebSocketChannel.connect(url);
    send(
      type: Type.INTRODUCTION,
      data: {"token": userProvider.token},
    );
  }

  void send({String type, dynamic data}) {
    if (!(type != Type.TASK_CREATED ||
        type != Type.TASK_UPDATED ||
        type != Type.OPERATOR_LOCATION_CREATED ||
        type != Type.INTRODUCTION ||
        type != Type.TASK_DELETED)) {
      print(
        "Websocket Unknown Message Type.\n" +
            "Message Type: $type\n" +
            "Data: ${data.toString()}",
      );
      return;
    }
    final dataWithType = json.encode({
      "type": type,
      "data": data,
    });
    _channel.sink.add(dataWithType);
  }

  void close() {
    _channel.sink.close();
  }

  void listen() {
    _channel.stream.listen((data) {
      _parseMessage(data);
    });
  }

  void _parseMessage(dynamic data) {
    try {
      final response = json.decode(data);
      final type = response["type"];
      switch (type) {
        case Type.VARIFIED:
          print("Websocket: Verified User");
          break;
        case Type.UNAUTHORIZATED:
          print("Websocket: Unauthorizated User");
          _unauthorizated();
          break;
        case Type.TASK_CREATED:
          print("Websocket: _taskCreated");
          _taskCreated(response["data"]);
          break;
        case Type.TASK_UPDATED:
          print("Websocket: _taskUpdated");
          _taskUpdated(response["data"]);
          break;
        case Type.OPERATOR_LOCATION_CREATED:
          print("Websocket: _locationCreated");
          _locationCreated(response["data"]);
          break;
        case Type.TASK_DELETED:
          print("Websocket: _taskDeleted");
          _taskDeleted(response["data"]);
          break;
        case Type.TASK_CREATED_NOTIFICATION:
          print("Websocket: _taskCreatedNotification");
          _taskCreatedNotification(response["data"]);
          break;
        case Type.TASK_UPDATED_NOTIFICATION:
          print("Websocket: _taskUpdatedNotification");
          _taskUpdatedNotification(response["data"]);
          break;
        default:
          print("Websocket: Unknown type state for message. Message ignored.");
          break;
      }
    } catch (error) {
      print('Error : ${error.toString()}');
      print('Data : ${data.toString()}');
    }
  }

  void _unauthorizated() {
    close();
  }

  void _taskCreated(Map<String, dynamic> data) {
    // final task = Task.fromJson(data);
    // print(task.toJson());
    // taskProvider.addLocalTask(task);
  }

  void _taskUpdated(Map<String, dynamic> data) {
    // final task = Task.fromJson(data);
    // print(task.toJson());
    // taskProvider.updateLocalTask(task);
  }

  void _taskDeleted(Map<String, dynamic> data) {
    // final task = Task.fromJson(data);
    // print(task.toJson());
    // taskProvider.deleteLocalTask(task);
  }

  void _locationCreated(Map<String, dynamic> data) {
    // final location = Location.fromJson(data);
    // print(location.toJson());
    // locationProvider.updateLocalCurrentLocation(location);
  }

  void _taskCreatedNotification(Map<String, dynamic> data) {
    // final task = ResponseTaskModel.fromJson(data);
    // createNotification(
    // "Görev Oluşturuldu",
    // "Sizin için yeni görev oluşturdu.",
    // );
  }

  void _taskUpdatedNotification(Map<String, dynamic> data) {
    // final task = ResponseTaskModel.fromJson(data);
    // createNotification(
    // "Görev Güncellendi",
    // "Oluşturduğunuz görevlerden biri güncellendi.",
    // );
  }
}
