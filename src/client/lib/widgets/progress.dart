import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final String text;
  ProgressWidget({this.text});
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          if (text != null)
            SizedBox(
              height: 8,
            ),
          if (text != null)
            Text(text, textAlign: TextAlign.center, style: style),
        ],
      ),
    );
  }
}
