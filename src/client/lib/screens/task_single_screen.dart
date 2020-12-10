import 'package:business_travel/models/task.dart';
import 'package:business_travel/widgets/info_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SingleTaskScreen extends StatelessWidget {
  final Task task;
  SingleTaskScreen({this.task});

  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  Widget createWidget(String identifier, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            identifier,
            style: style,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Görev',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                InformationLine('Görev:', task.name),
                Divider(),
                InformationLine('Görev id:', task.id.toString()),
                Divider(),
                InformationLine('Açıklama:', task.description),
                Divider(),
                InformationLine(
                  'Başlangıç Tarihi:',
                  DateFormat.yMd().format(task.startedAt),
                ),
                InformationLine(
                  'Bitiş Tarihi:',
                  DateFormat.yMd().format(task.finishedAt),
                ),
                InformationLine(
                  'Oluşturulma Tarihi:',
                  DateFormat.yMd().format(task.createdAt),
                ),
                Divider(),
                InformationLine(
                  'Lokasyon:',
                  '${task.location.latitude.toStringAsFixed(4)}' +
                      ' ${task.location.longitude.toStringAsFixed(4)}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
