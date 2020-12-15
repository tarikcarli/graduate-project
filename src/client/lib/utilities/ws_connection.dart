import 'dart:convert';

import 'package:business_travel/utilities/global_provider.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:web_socket_channel/io.dart';
// import '../helpers/notification.dart';

class Type {
  static const AUTHORIZATION = "AUTHORIZATION";
  static const UNAUTHORIZATED = "UNAUTHORIZATED";
  static const TASK_ADD = "TASK_ADD";
  static const TASK_UPDATE = "TASK_UPDATED";
  static const TASK_DELETE = "TASK_DELETED";
  static const OPERATOR_LOCATION_ADD = "OPERATOR_LOCATION_ADD";
  static const OPERATOR_ENTER_TASK = "OPERATOR_ENTER_TASK";
  static const OPERATOR_LEAVE_TASK = "OPERATOR_LEAVE_TASK";
  static const OPERATOR_ADD = "OPERATOR_ADD";
  static const OPERATOR_REMOVE = "OPERATOR_REMOVE";
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
        case Type.OPERATOR_ENTER_TASK:
          print("Websocket: _taskCreatedNotification");
          _operatorEnterTask(response["data"]);
          break;
        case Type.OPERATOR_LEAVE_TASK:
          print("Websocket: _taskUpdatedNotification");
          _operatorLeaveTask(response["data"]);
          break;
        case Type.OPERATOR_ADD:
          _operatorAdd(response["data"]);
          break;
        case Type.OPERATOR_REMOVE:
          _operatorRemove(response["data"]);
          break;
        case Type.INVOICE_ADD:
          _invoideAdd(response["data"]);
          break;
        case Type.INVOICE_UPDATE:
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

  void _taskAdd(Map<String, dynamic> data) {}

  void _taskUpdate(Map<String, dynamic> data) {}

  void _taskDelete(Map<String, dynamic> data) {}

  void _operatorLocationAdd(Map<String, dynamic> data) {}

  void _operatorEnterTask(Map<String, dynamic> data) {}

  void _operatorLeaveTask(Map<String, dynamic> data) {}

  void _operatorAdd(Map<String, dynamic> data) {}

  void _operatorRemove(Map<String, dynamic> data) {}

  void _invoideAdd(Map<String, dynamic> data) {}

  void _invoiceUpdate(Map<String, dynamic> data) {}
}
