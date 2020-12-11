import 'package:flutter/cupertino.dart';

class InformationLine extends StatelessWidget {
  final String identifier;
  final String data;
  InformationLine(this.identifier, this.data);
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            identifier,
            style: style.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            data,
            style: style,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
