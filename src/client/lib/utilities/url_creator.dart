import 'package:flutter/foundation.dart';

class URL {
  static const httpUrl = 'http://207.154.227.232:4000/'; //  OCEAN
  static const wsUrl = 'ws://207.154.227.232:4000/'; //  OCEAN
  // static const httpUrl = 'http://192.168.1.43:4000/'; //  HOME
  // static const wsUrl = 'ws://192.168.1.43:4000/'; //  HOME
  static Map<String, String> jsonHeader({String token}) {
    final headers = {"Content-type": "application/json"};
    if (token != null) headers['authorization'] = 'Bearer $token';
    return headers;
  }

  static String getServerStatus() {
    return '${httpUrl}api/status/server';
  }

  static String getTokenStatus() {
    return '${httpUrl}api/status/token';
  }

  static String getBinaryPhoto({@required String path}) {
    return '${httpUrl}images/$path.jpg';
  }

  static String getPhoto({@required int id}) {
    return '${httpUrl}api/photo/?id=$id';
  }

  static String postPhoto() {
    return '${httpUrl}api/photo/';
  }

  static String putPhoto() {
    return '${httpUrl}api/photo/';
  }

  static String register() {
    return '${httpUrl}api/user/register';
  }

  static String login() {
    return '${httpUrl}api/user/login';
  }

  static String updateUser() {
    return '${httpUrl}api/user/update';
  }

  static String assignOperator() {
    return '${httpUrl}api/user/operator/assign';
  }

  static String unassignOperator() {
    return '${httpUrl}api/user/operator/unassign';
  }

  static String updateRole() {
    return '${httpUrl}api/user/update/role';
  }

  static String updatePassword() {
    return '${httpUrl}api/user/update/password';
  }

  static String logout({@required int id}) {
    return '${httpUrl}api/user/logout?id=$id';
  }

  static String getOperators({@required int adminId}) {
    return '${httpUrl}api/user/operators?adminId=$adminId';
  }

  static String getAdmin({@required int operatorId}) {
    return '${httpUrl}api/user/admin?operatorId=$operatorId';
  }

  static String getOperatorIds({@required int adminId}) {
    return '${httpUrl}api/user/operatorIds?adminId=$adminId';
  }

  static String getMe({@required int id}) {
    return '${httpUrl}api/user/me?id=$id';
  }

  static String deleteOperator({@required int id}) {
    return '${httpUrl}api/user/operator?id=$id';
  }

  static String getAllUsers() {
    return '${httpUrl}api/user/all';
  }

  static String postLocation() {
    return '${httpUrl}api/location';
  }

  static String postUserLocation() {
    return '${httpUrl}api/user/location';
  }

  static String postUserLocations() {
    return '${httpUrl}api/user/locations';
  }

  static String getLocation({@required id}) {
    return '${httpUrl}api/location?id=$id';
  }

  static String getCurrentLocation({@required int operatorId}) {
    return '${httpUrl}api/user/location/current?operatorId=$operatorId';
  }

  static String getHistoryLocation({
    @required int operatorId,
    @required DateTime startDate,
    @required DateTime finishDate,
  }) {
    return '${httpUrl}api/user/location/history?operatorId=$operatorId&startDate=${startDate.toIso8601String()}&finishDate=${finishDate.toIso8601String()}';
  }

  static String getTotalTask({int operatorId, int adminId, bool isComplete}) {
    if (operatorId != null)
      return '${httpUrl}api/task/total?isComplete=$isComplete&operatorId=$operatorId';
    if (adminId != null)
      return '${httpUrl}api/task/total?isComplete=$isComplete&adminId=$adminId';
    return null;
  }

  static String postTask() {
    return '${httpUrl}api/task';
  }

  static String getTask({int id, int operatorId, int adminId}) {
    if (id != null) return '${httpUrl}api/task?id=$id';
    if (operatorId != null) return '${httpUrl}api/task?operatorId=$operatorId';
    if (adminId != null) return '${httpUrl}api/task?adminId=$adminId';
    return null;
  }

  static String putTask({@required id}) {
    return '${httpUrl}api/task?id=$id';
  }

  static String deleteTask({@required id}) {
    return '${httpUrl}api/task?id=$id';
  }

  static String postInvoice() {
    return '${httpUrl}api/invoice';
  }

  static String getInvoice({int id, int taskId, int operatorId, int adminId}) {
    if (id != null) return '${httpUrl}api/invoice?id=$id';
    if (taskId != null) return '${httpUrl}api/invoice?taskId=$taskId';
    if (operatorId != null)
      return '${httpUrl}api/invoice?operatorId=$operatorId';
    if (adminId != null) return '${httpUrl}api/invoice?adminId=$adminId';
    return null;
  }

  static String putInvoice({@required id}) {
    return '${httpUrl}api/invoice?id=$id';
  }

  static String sendInvoiceMail({@required id}) {
    return '${httpUrl}api/invoice/sendmail?id=$id';
  }

  static getCity() {
    return '${httpUrl}api/city';
  }
}
