import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String buttonName;
  final GestureTapCallback onPressed;
  ButtonWidget({@required this.onPressed, this.buttonName});

  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: double.infinity,
      height: MediaQuery.of(context).size.height * 0.06,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36.0),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
          )),
      child: RaisedButton(
        color: Theme.of(context).primaryColor,
        onPressed: onPressed,
        child: Text(
          buttonName.toString(),
          textAlign: TextAlign.center,
          style: style.copyWith(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
