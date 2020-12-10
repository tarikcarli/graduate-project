import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final GestureTapCallback onPressed;
  final bool success;
  DialogWidget({
    @required this.onPressed,
    this.title,
    this.success = false,
    this.content,
  });

  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: new Column(
        children: <Widget>[
          new Text(title.toString()),
          new Icon(
            success ? Icons.check_circle : Icons.warning,
            color: success ? Colors.green : Colors.orange,
          ),
        ],
      ),
      content: new Text(content.toString()),
      actions: <Widget>[
        new FlatButton(onPressed: onPressed, child: new Text("OK")),
      ],
    );
  }
}
