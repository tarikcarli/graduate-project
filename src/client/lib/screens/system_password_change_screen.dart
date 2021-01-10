import 'package:business_travel/models/user.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../widgets/button_widget.dart';

class PasswordChangeScreen extends StatefulWidget {
  final User user;
  PasswordChangeScreen(this.user);
  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  UserProvider _userProvider;
  final _form = GlobalKey<FormState>();
  bool _isLoading = false;
  String _password = "";
  String _passwordVal = "";
  bool _obscureText = true;
  bool _obscureValText = true;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  void _saveForm() async {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        await _userProvider.updatePassword(
          id: widget.user.id,
          password: _password,
        );
      } catch (error) {
        await CustomDialog.show(
          ctx: context,
          withCancel: false,
          title: "Sunucudan Bilgi Alınamıyor",
          content: "Durum: ${error.toString()}",
        );
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleVal() {
    setState(() {
      _obscureValText = !_obscureValText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Şifre Yenileme",
          style: style.copyWith(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      body: _isLoading
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Şifre',
                                ),
                                initialValue: _password,
                                textInputAction: TextInputAction.next,
                                obscureText: _obscureText,
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Kayıt olmak için bu alan gereklidir.';
                                  if (value.length < 8)
                                    return 'Şifre en az 8 karakter uzunluğunda olmalıdır.';
                                  if (_password != _passwordVal)
                                    return "Şifreler birbirinin aynısı olmalıdır.";
                                  return null;
                                },
                                onChanged: (value) {
                                  _password = value;
                                },
                                onSaved: (value) {
                                  _password = value;
                                },
                              ),
                            ),
                            Expanded(
                              child: FlatButton(
                                  onPressed: _toggle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Icon(_obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  )),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Şifre Tekrar',
                                ),
                                initialValue: _passwordVal,
                                textInputAction: TextInputAction.done,
                                obscureText: _obscureValText,
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Kayıt olmak için bu alan gereklidir.';
                                  if (value.length < 8)
                                    return 'Şifre en az 8 karakter uzunluğunda olmalıdır.';
                                  if (_password != _passwordVal)
                                    return "Şifreler birbirinin aynısı olmalıdır.";
                                  return null;
                                },
                                onChanged: (value) {
                                  _passwordVal = value;
                                },
                                onSaved: (value) {
                                  _passwordVal = value;
                                },
                              ),
                            ),
                            Expanded(
                              child: FlatButton(
                                  onPressed: _toggleVal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Icon(_obscureValText
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  )),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: ButtonWidget(
                          onPressed: _saveForm,
                          buttonName: 'Güncelle',
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
