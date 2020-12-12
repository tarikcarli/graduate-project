import 'package:business_travel/providers/user.dart';
import 'package:business_travel/utilities/image_convert.dart';
import 'package:business_travel/utilities/photo_service.dart';
import 'package:business_travel/utilities/ready_image.dart';
import 'package:business_travel/utilities/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthMode { Register, Login }

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.5),
                  Theme.of(context).accentColor.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: size.height,
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/blue_map.jpg'),
                          fit: BoxFit.fill,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Flexible(
                    flex: 40,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  UserProvider _userProvider;
  AuthMode _authMode = AuthMode.Login;
  bool _obscurePasswordText = true;
  bool _obscurePasswordValText = true;

  String _email = "";
  String _password = "";
  String _name = "";
  String _photo;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  Future<void> _submit() async {
    try {
      if (!_formKey.currentState.validate()) {
        return;
      }
      _formKey.currentState.save();
      if (_authMode == AuthMode.Login) {
        await _userProvider.login(email: _email, password: _password);
      }
      if (_authMode == AuthMode.Register) {
        final photo = await PhotoService.postPhoto(photo: _photo);
        await _userProvider.register(
            name: _name, email: _email, password: _password, photoId: photo.id);
        _switchAuthMode();
      }
    } catch (err) {
      await CustomDialog.show(
        ctx: context,
        title: _authMode == AuthMode.Login ? "Login Error" : "Register Error",
        content: err.toString(),
        withCancel: false,
      );
    }
  }

  void _iconOnTab(bool isCamera) async {
    _formKey.currentState.save();
    final photo = await selectImage(isCamera: isCamera);
    setState(() {
      _photo = photo;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePasswordText = !_obscurePasswordText;
    });
  }

  void _togglePasswordValVisibility() {
    setState(() {
      _obscurePasswordValText = !_obscurePasswordValText;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login)
      _authMode = AuthMode.Register;
    else
      _authMode = AuthMode.Login;
    setState(() {
      _obscurePasswordText = true;
      _obscurePasswordValText = true;
      _password = "";
      _email = "";
      _name = "";
      _photo = null;
    });
    _formKey.currentState.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (_authMode == AuthMode.Register)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: GestureDetector(
                          onTap: () => _iconOnTab(false),
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Icon(Icons.photo),
                            ),
                          ),
                        ),
                      ),
                      if (_photo != null)
                        CircleAvatar(
                          backgroundImage: MemoryImage(
                            ImageConvert.dataFromBase64String(_photo),
                          ),
                        ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: GestureDetector(
                          onTap: () => _iconOnTab(true),
                          child: FittedBox(
                            child: Icon(Icons.camera_alt),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value;
                  },
                  onChanged: (value) {
                    _email = value;
                  },
                ),
                if (_authMode == AuthMode.Register)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Invalid name!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value;
                    },
                    onChanged: (value) {
                      _name = value;
                    },
                  ),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        initialValue: "12345678", //_password,
                        obscureText: _obscurePasswordText,
                        validator: (value) {
                          if (value.isEmpty || value.length < 4) {
                            return 'Password is too short!';
                          }
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
                          onPressed: _togglePasswordVisibility,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Icon(!_obscurePasswordText
                                ? Icons.visibility
                                : Icons.visibility_off),
                          )),
                    ),
                  ],
                ),
                if (_authMode == AuthMode.Register)
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Confirm Password'),
                          initialValue: _password,
                          obscureText: _obscurePasswordValText,
                          validator: (value) {
                            if (value != _password)
                              return "Şifreler birbirinin aynısı olmalıdır.";
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                            onPressed: _togglePasswordValVisibility,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Icon(!_obscurePasswordValText
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            )),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: RaisedButton(
                        child: Text(
                            _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                        onPressed: _submit,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        color: Theme.of(context).primaryColor,
                        textColor:
                            Theme.of(context).primaryTextTheme.button.color,
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                        child: Text(
                            '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'}'),
                        onPressed: _switchAuthMode,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
