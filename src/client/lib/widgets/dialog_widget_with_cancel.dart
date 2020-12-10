import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogWidgetWithCancel extends StatelessWidget {
  final String title;
  final String content;
  final GestureTapCallback onPressedCancel;
  final GestureTapCallback onPressedOk;
  DialogWidgetWithCancel({
    @required this.onPressedOk,
    this.onPressedCancel,
    this.title,
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
            Icons.warning,
            color: Colors.orange,
          ),
        ],
      ),
      content: new Text(content.toString()),
      actions: <Widget>[
        new FlatButton(onPressed: onPressedCancel, child: new Text("İptal")),
        new FlatButton(onPressed: onPressedOk, child: new Text("OK")),
      ],
    );
  }
}
