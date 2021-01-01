import 'dart:convert';

import 'package:business_travel/models/location.dart';
import 'package:business_travel/utilities/global_provider.dart';
import 'package:business_travel/utilities/notification.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:web_socket_channel/io.dart';

class Type {
  static const AUTHORIZATION = "AUTHORIZATION";
  static const UNAUTHORIZATED = "UNAUTHORIZATED";
  static const TASK_ADD = "TASK_ADD";
  static const TASK_UPDATE = "TASK_UPDATE";
  static const TASK_DELETE = "TASK_DELETE";
  static const OPERATOR_LOCATION_ADD = "OPERATOR_LOCATION_ADD";
  static const OPERATOR_ENTER_NOTIFICATION = "OPERATOR_ENTER_NOTIFICATION";
  static const OPERATOR_LEAVE_NOTIFICATION = "OPERATOR_LEAVE_NOTIFICATION";
  static const TASK_ADD_NOTIFICATION = "TASK_ADD_NOTIFICATION";
  static const INVOICE_ADD_NOTIFICATION = "INVOICE_ADD_NOTIFICATION";
  static const INVOICE_UPDATE_NOTIFICATION = "INVOICE_UPDATE_NOTIFICATION";
  static const OPERATOR_ADD = "OPERATOR_ADD";
  static const OPERATOR_REMOVE = "OPERATOR_REMOVE";
  static const ADMIN_ADD = "ADMIN_ADD";
  static const ADMIN_REMOVE = "ADMIN_REMOVE";
  static const INVOICE_ADD = "INVOICE_ADD";
  static const INVOICE_UPDATE = "INVOICE_UPDATE";
}

class WebSocket {
  IOWebSocketChannel _channel;

  void open() {
    print("ws open");
    _channel = IOWebSocketChannel.connect(URL.wsUrl);
    send(
      type: Type.AUTHORIZATION,
      data: {
        "token": MyProvider.user.token,
        "id": MyProvider.user.user.id,
      },
    );
    listen();
  }

  void send({String type, dynamic data}) {
    final dataWithType = json.encode({
      "type": type,
      "data": data,
    });
    _channel.sink.add(dataWithType);
  }

  void close() {
    print("ws close");
    _channel.sink.close();
  }

  void listen() {
    _channel.stream.listen((data) {
      _parseMessage(data);
    });
  }

  void _parseMessage(dynamic data) {
    try {
      print(data.toString());
      final response = json.decode(data);
      final type = response["type"];
      switch (type) {
        case Type.AUTHORIZATION:
          print("Websocket: Verified User");
          break;
        case Type.UNAUTHORIZATED:
          print("Websocket: UnVerified User");
          break;
        case Type.TASK_ADD:
          print("Websocket: _taskCreated");
          _taskAdd(response["data"]);
          break;
        case Type.TASK_UPDATE:
          print("Websocket: _taskUpdated");
          _taskUpdate(response["data"]);
          break;
        case Type.TASK_DELETE:
          print("Websocket: _locationCreated");
          _taskDelete(response["data"]);
          break;
        case Type.OPERATOR_LOCATION_ADD:
          print("Websocket: _taskDeleted");
          _operatorLocationAdd(response["data"]);
          break;
        case Type.OPERATOR_ENTER_NOTIFICATION:
          print("Websocket: _operatorEnterNotification");
          _operatorEnterNotification();
          break;
        case Type.OPERATOR_LEAVE_NOTIFICATION:
          print("Websocket: _operatorLeaveNotification");
          _operatorLeaveNotification();
          break;
        case Type.TASK_ADD_NOTIFICATION:
          print("Websocket: _taskAddNotification");
          _taskAddNotification();
          break;
        case Type.INVOICE_ADD_NOTIFICATION:
          print("Websocket: _invoiceAddNotification");
          _invoiceAddNotification();
          break;
        case Type.INVOICE_UPDATE_NOTIFICATION:
          print("Websocket: _invoiceUpdateNotification");
          _invoiceUpdateNotification();
          break;

        case Type.OPERATOR_ADD:
          print("Websocket: _operatorAdd");
          _operatorAdd(response["data"]);
          break;
        case Type.OPERATOR_REMOVE:
          print("Websocket: _operatorRemove");
          _operatorRemove(response["data"]);
          break;
        case Type.ADMIN_ADD:
          print("Websocket: _adminAdd");
          _adminAdd(response["data"]);
          break;
        case Type.ADMIN_REMOVE:
          print("Websocket: _adminRemove");
          _adminRemove(response["data"]);
          break;
        case Type.INVOICE_ADD:
          print("Websocket: _invoiceAdd");
          _invoideAdd(response["data"]);
          break;
        case Type.INVOICE_UPDATE:
          print("Websocket: _invoiceUpdate");
          _invoiceUpdate(response["data"]);
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

  void _taskAdd(Map<String, dynamic> data) {
    try {
      MyProvider.task.fetchAndSetTasks(
        token: MyProvider.user.token,
        operatorId: MyProvider.user.user.id,
      );
    } catch (error) {
      print("Error _taskAdd : $error");
    }
  }

  void _taskUpdate(Map<String, dynamic> data) {
    try {
      MyProvider.task.fetchAndSetTasks(
        token: MyProvider.user.token,
        operatorId: MyProvider.user.user.id,
      );
    } catch (error) {
      print("Error _taskUpdate : $error");
    }
  }

  void _taskDelete(Map<String, dynamic> data) {
    try {
      MyProvider.task.fetchAndSetTasks(
        token: MyProvider.user.token,
        operatorId: MyProvider.user.user.id,
      );
    } catch (error) {
      print("Error _taskDelete : $error");
    }
  }

  void _operatorLocationAdd(Map<String, dynamic> data) {
    try {
      MyProvider.location.updateLocalCurrentLocation(Location.fromJson(data));
    } catch (error) {
      print("Error _operatorLocationAdd : $error");
    }
  }

  void _operatorEnterNotification() {
    createNotification(
      "Görev Bildirimi",
      "Çalışan görev bildirim alanına girdi.",
    );
  }

  void _operatorLeaveNotification() {
    createNotification(
      "Görev Bildirimi",
      "Çalışan görev bildirim alanından çıktı.",
    );
  }

  void _taskAddNotification() {
    createNotification(
      "Görev Bildirimi",
      "Yöneticiniz size bir görev atadı.",
    );
  }

  void _invoiceAddNotification() {
    createNotification(
      "Fatura Bildirimi",
      "Çalışanınız yeni fatura yükledi.",
    );
  }

  void _invoiceUpdateNotification() {
    createNotification(
      "Fatura Bildirimi",
      "Faturanıza cevap geldi.",
    );
  }

  void _operatorAdd(Map<String, dynamic> data) {
    try {
      MyProvider.user.getOperators();
    } catch (error) {
      print("Error _operatorAdd : $error");
    }
  }

  void _operatorRemove(Map<String, dynamic> data) {
    try {
      MyProvider.user.getOperators();
    } catch (error) {
      print("Error _operatorRemove : $error");
    }
  }

  Future<void> _adminAdd(Map<String, dynamic> data) async {
    try {
      await MyProvider.user.getMe(id: MyProvider.user.user.id);
      await MyProvider.user.getAdmin();
    } catch (error) {
      print("Error _adminAdd : $error");
    }
  }

  void _adminRemove(Map<String, dynamic> data) async {
    try {
      await MyProvider.user.getMe(id: MyProvider.user.user.id);
      await MyProvider.user.getAdmin();
    } catch (error) {
      print("Error _adminRemove : $error");
    }
  }

  void _invoideAdd(Map<String, dynamic> data) {
    MyProvider.invoice.fetchAndSetInvoices(
      token: MyProvider.user.token,
      adminId: MyProvider.user.user.id,
    );
  }

  void _invoiceUpdate(Map<String, dynamic> data) {
    if (MyProvider.user.user.role == "admin")
      MyProvider.invoice.fetchAndSetInvoices(
        token: MyProvider.user.token,
        adminId: MyProvider.user.user.id,
      );
    else
      MyProvider.invoice.fetchAndSetInvoices(
        token: MyProvider.user.token,
        operatorId: MyProvider.user.user.id,
      );
  }
}
