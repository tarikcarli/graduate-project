import 'dart:convert';

import 'package:business_travel/models/user.dart';
import 'package:business_travel/utilities/photo_service.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:business_travel/utilities/ws_connection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  final storage = new FlutterSecureStorage();
  WebSocket _ws;
  String token;
  User user;
  User admin;
  List<User> operators = [];
  List<User> users = [];

  String operatorIdToName(operatorId) {
    if (operatorId == user.id) return user.name;
    final op = operators.firstWhere(
      (element) => element.id == operatorId,
      orElse: () => null,
    );
    return op?.name;
  }

  User finByOperatorId(operatorId) {
    if (operatorId == user.id) return user;
    final op = operators.firstWhere(
      (element) => element.id == operatorId,
      orElse: () => null,
    );
    return op;
  }

  List<int> operatorIds() {
    return operators.map((element) => element.id).toList();
  }

  void sortUser() {
    users.sort((User user1, User user2) => user1.id.compareTo(user2.id));
  }

  Future<List<int>> adminOperatorIds({adminId}) async {
    http.Response response;
    try {
      response = await http.get(
        URL.getOperatorIds(adminId: adminId),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        List<int> operatorIds = [];
        json.decode(response.body)['data'].forEach((element) {
          operatorIds.add(element);
        });
        return operatorIds;
      }
    } catch (error) {
      print("Error adminOperatorIds: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> getAllUser() async {
    http.Response response;
    try {
      response = await http.get(
        URL.getAllUsers(),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        users = [];
        json.decode(response.body)['data'].forEach((element) {
          final user = User.fromJson(element);
          if (user.role != "system") users.add(user);
        });
        sortUser();
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error getAllUser: $error");
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  void updateUserLocal({@required id, @required role}) {
    try {
      final user = users.firstWhere(
        (element) => element.id == id,
        orElse: () => null,
      );
      if (user != null) {
        user.role = role;
      }
    } catch (error) {
      print("Error updateUserLocal" + error.toString());
    }
  }

  Future<void> updateUser({
    @required int id,
    @required int photoId,
    @required String photo,
    @required String name,
    @required String email,
    @required String role,
  }) async {
    http.Response response;
    try {
      if (photo != null) await PhotoService.putPhoto(id: photoId, photo: photo);
      response = await http.put(
        URL.updateRole(),
        headers: URL.jsonHeader(token: token),
        body: json.encode(
          {
            "data": {
              "id": id,
              "role": role,
            },
          },
        ),
      );
      response = await http.put(
        URL.updateUser(),
        headers: URL.jsonHeader(token: token),
        body: json.encode(
          {
            "data": {
              "id": id,
              "name": name,
              "email": email,
            },
          },
        ),
      );
      if (response.statusCode == 200) {
        return;
      }
    } catch (error) {
      print("Error updateUser" + error.toString());
      throw error;
    }
    if (response.statusCode == 409)
      throw Exception(
        "Bu email ile kayıtlı kullanıcı bulunmaktadır.",
      );
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> updatePassword({
    @required int id,
    @required String password,
  }) async {
    http.Response response;
    try {
      response = await http.put(
        URL.updatePassword(),
        headers: URL.jsonHeader(token: token),
        body: json.encode(
          {
            "data": {
              "id": id,
              "password": password,
            },
          },
        ),
      );
      if (response.statusCode == 200) {
        return;
      }
    } catch (error) {
      print("Error updatePassword" + error.toString());
      throw error;
    }
    if (response.statusCode == 401)
      throw Exception(
        'Şifre bilgisi hatalıdır. ' +
            'Hatırlayamıyorsanız lütfen yöneticinizle iletişime geçiniz.',
      );
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> getMe({@required int id}) async {
    http.Response response;
    try {
      response = await http.get(
        URL.getMe(id: id),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        user = User.fromJson(json.decode(response.body)['data']);
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error getMe" + error.toString());
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> deleteOperator(int id) async {
    http.Response response;
    try {
      response = await http.delete(
        URL.deleteOperator(id: id),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        users.removeWhere((e) {
          return e.id == id;
        });
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error deleteUser" + error.toString());
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> assignOperator({int adminId, int operatorId}) async {
    http.Response response;
    try {
      response = await http.post(
        URL.assignOperator(),
        headers: URL.jsonHeader(token: token),
        body: json.encode(
          {
            "data": {
              "adminId": adminId,
              "operatorId": operatorId,
            },
          },
        ),
      );
      if (response.statusCode == 200) {
        return;
      }
    } catch (error) {
      print("Error assignOperator" + error.toString());
      throw error;
    }
    if (response.statusCode == 409)
      throw Exception(
        "Bu operatorün admini mevcuttur.",
      );
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> unassignOperator({int adminId, int operatorId}) async {
    http.Response response;
    try {
      response = await http.post(
        URL.unassignOperator(),
        headers: URL.jsonHeader(token: token),
        body: json.encode(
          {
            "data": {
              "adminId": adminId,
              "operatorId": operatorId,
            },
          },
        ),
      );
      if (response.statusCode == 200) {
        return;
      }
    } catch (error) {
      print("Error unasssignOperator" + error.toString());
      throw error;
    }
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> register({
    @required String name,
    @required String email,
    @required String password,
    @required int photoId,
  }) async {
    http.Response response;
    try {
      response = await http.post(
        URL.register(),
        headers: URL.jsonHeader(),
        body: json.encode(
          {
            "data": {
              "name": name,
              "email": email,
              "password": password,
              "photoId": photoId,
            },
          },
        ),
      );
      if (response.statusCode == 200) {
        return;
      }
    } catch (err) {
      print("Error UserProvider.register: $err");
      throw err;
    }
    if (response.statusCode == 409)
      throw Exception(
        "Bu email ile kayıtlı kullanıcı bulunmaktadır.",
      );
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> login({
    @required String email,
    @required String password,
  }) async {
    http.Response response;
    try {
      response = await http.post(
        URL.login(),
        headers: URL.jsonHeader(),
        body: json.encode(
          {
            "data": {
              "email": email,
              "password": password,
            },
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)["data"];
        token = data["token"];
        user = User.fromJson(data);
        storage.write(key: "token", value: token);
        storage.write(key: "id", value: user.id.toString());
        if (user.role == "admin") getOperators();
        if (user.role == "operator") getAdmin();
        _ws = WebSocket();
        _ws.open();
        notifyListeners();
        return;
      }
    } catch (err) {
      print("Error UserProvider.login: $err");
      throw err;
    }
    if (response.statusCode == 400)
      throw new Exception(
        "Email veya şifre bilgisi hatalıdır. Lütfen tekrar deneyiniz.\n Şifrenizi unuttuysanız, şifrenizi yenileyebilirsiniz.",
      );

    if (response.statusCode == 401)
      throw new Exception(
        "Email veya şifre bilgisi hatalıdır. Lütfen tekrar deneyiniz.\n Şifrenizi unuttuysanız, şifrenizi yenileyebilirsiniz.",
      );
    if (response.statusCode == 403)
      throw new Exception(
        "Giriş yapabilmek için sistem yöneticisi veya kendi yöneticinizle görüşmelisiniz.\nOnaylanmayan kullanıcılar giriş yapamazlar.",
      );
    throw new Exception(
      "Unknown Error: http status code ${response.statusCode}",
    );
  }

  Future<void> getOperators() async {
    http.Response response;
    try {
      response = await http.get(
        URL.getOperators(adminId: user.id),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        operators = [];
        json.decode(response.body)["data"].forEach((e) {
          operators.add(User.fromJson(e));
        });
        notifyListeners();
        return;
      }
    } catch (error) {
      print("Error getOperators: $error");
      throw error;
    }
    if (response.statusCode == 401)
      throw Exception(
          'Operatorleri görüntülüyebilmek için yönetici rolünde olmalısınız.');
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> getAdmin() async {
    http.Response response;
    try {
      response = await http.get(
        URL.getAdmin(operatorId: user.id),
        headers: URL.jsonHeader(token: token),
      );
      if (response.statusCode == 200) {
        admin = User.fromJson(json.decode(response.body)["data"]);
        return;
      }
    } catch (error) {
      print("Error getAdmin: $error");
      throw error;
    }
    if (response.statusCode == 401)
      throw Exception(
          'Adminlerinizi görüntülüyebilmek için operator rolünde olmalısınız.');
    throw Exception('Bilinmeyen bir hata oluştu.\n' +
        'Http hata kodu: ${response.statusCode}');
  }

  Future<void> logout() async {
    try {
      int argId = user?.id;
      String argToken = token;
      token = null;
      // user = null;
      // admin = null;
      users = [];
      operators = [];
      storage.delete(key: "token");
      storage.delete(key: "id");
      _ws.close();
      notifyListeners();
      await http.post(
        URL.logout(id: argId),
        headers: URL.jsonHeader(token: argToken),
      );
      return;
    } catch (error) {
      print("Error UserProvider.logout: $error");
      throw error;
    }
  }

  Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(URL.getServerStatus());
      return response.statusCode == 200;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> checkTokenStatus({String token}) async {
    try {
      final response = await http.get(
        URL.getTokenStatus(),
        headers: URL.jsonHeader(token: token),
      );
      return response.statusCode == 200;
    } catch (error) {
      print(error);
      return false;
    }
  }

  String userIdToUserName(int userId) {
    final instance = operators.firstWhere((element) => element.id == userId,
        orElse: () => null);
    return '${instance?.name}';
  }

  String userIdToPhoto(int userId) {
    try {
      if (operators.length == 0) {
        return user.photo.path;
      }
      final instance = operators.firstWhere(
        (element) => element.id == userId,
      );
      if (instance != null) return instance.photo.path;
    } catch (error) {
      print(error);
    }
    return null;
  }

  Future<void> checkUserInfo() async {
    try {
      final storage = new FlutterSecureStorage();
      String storedToken = await storage.read(key: 'token');
      if (storedToken != null) {
        int id = int.tryParse(await storage.read(key: 'id'));
        bool runningServer = await checkServerStatus();
        bool validUser = await checkTokenStatus(token: storedToken);
        if (runningServer && validUser) {
          await getMe(id: id);
          token = storedToken;
          if (user.role == "admin") await getOperators();
          if (user.role == "operator") await getAdmin();
          _ws = WebSocket();
          _ws.open();
          notifyListeners();
        }
      }
    } catch (error) {
      print("Error checkUserInfo: $error");
    }
  }
}
