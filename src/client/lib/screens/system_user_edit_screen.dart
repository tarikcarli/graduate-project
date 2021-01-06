import 'package:business_travel/models/user.dart';
import 'package:business_travel/providers/user.dart';
import 'package:business_travel/screens/system_password_change_screen.dart';
import 'package:business_travel/utilities/image_convert.dart';
import 'package:business_travel/utilities/ready_image.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:business_travel/widgets/button_widget.dart';
import 'package:business_travel/widgets/drawer_widget.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserEditScreen extends StatefulWidget {
  final User user;
  UserEditScreen(this.user);
  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  UserProvider _userProvider;
  final _form = GlobalKey<FormState>();
  String _photo;
  String _name;
  String _email;
  String _role;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _name = widget.user.name;
    _email = widget.user.email;
    _role = widget.user.role;
  }

  Future<void> getMe() async {
    await _userProvider.getMe(id: _userProvider.user.id);
  }

  int roleToInt(String role) {
    if (role == "admin") return 1;
    if (role == "operator") return 2;
    if (role == "other") return 3;
    return 3;
  }

  String intToRole(int role) {
    if (role == 1) return "admin";
    if (role == 2) return "operator";
    if (role == 3) return "other";
    return "other";
  }

  void updateOnTab() async {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      setState(() {
        loading = true;
      });
      try {
        await _userProvider.updateUser(
            id: widget.user.id,
            photoId: widget.user.photo.id,
            name: _name,
            email: _email,
            photo: _photo,
            role: _role);
        if (_userProvider.user.role != "system") getMe();
      } catch (error) {
        print("Error updateOnTab $error");
        await CustomDialog.show(
          ctx: context,
          withCancel: false,
          title: "Sunucudan Bilgi Alınamıyor",
          content: "Durum: ${error.toString()}",
        );
      }
      setState(() {
        loading = false;
      });
      if (_userProvider.user.role == "system") Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
      ),
      drawer: _userProvider.user.role == "system" ? null : DrawerWidget(),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            )
          : Form(
              key: _form,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        child: CircleAvatar(
                          backgroundImage: _photo != null
                              ? MemoryImage(
                                  ImageConvert.dataFromBase64String(_photo),
                                )
                              : NetworkImage(
                                  URL.getBinaryPhoto(
                                      path: widget.user.photo.path),
                                ),
                          radius: MediaQuery.of(context).size.width * 0.25,
                        ),
                        onTap: () async {
                          final photo = await selectImage(isCamera: false);
                          if (photo != null)
                            setState(() {
                              _photo = photo;
                            });
                        },
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'İsim',
                          ),
                          initialValue: _name,
                          validator: (value) {
                            if (value.isEmpty)
                              return 'Giriş yapmak için bu alan gereklidir.';
                            if (value.length < 2)
                              return 'İsminiz en az 2 karakter içermelidir.';
                            return null;
                          },
                          onChanged: (value) {
                            _name = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                          ),
                          initialValue: _email,
                          validator: (value) {
                            if (!value.contains("@"))
                              return 'Email gereklidir.';
                            return null;
                          },
                          onChanged: (value) {
                            _email = value;
                          },
                        ),
                      ),
                      if (_userProvider.user.role == "system")
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: DropDownFormField(
                            titleText: 'Rol',
                            contentPadding: null,
                            value: roleToInt(_role),
                            filled: false,
                            onChanged: (value) {
                              setState(() {
                                _role = intToRole(value);
                              });
                            },
                            validator: (value) {
                              if (_role == null)
                                return "Güncellemek için role belirlemelisiniz.";
                              return null;
                            },
                            required: true,
                            dataSource: [
                              {"value": 1, "display": "Yönetici"},
                              {"value": 2, "display": "Çalışan"},
                              {"value": 3, "display": "Diğer"}
                            ],
                            textField: 'display',
                            valueField: 'value',
                          ),
                        ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ButtonWidget(
                          buttonName: "Güncelle",
                          onPressed: updateOnTab,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ButtonWidget(
                          buttonName: "Şifre Güncelle",
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    PasswordChangeScreen(widget.user),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
