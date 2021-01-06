import 'package:business_travel/models/user.dart';
import 'package:business_travel/utilities/url_creator.dart';
import 'package:business_travel/widgets/info_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SingleOperatorScreen extends StatelessWidget {
  final User user;
  SingleOperatorScreen({this.user});

  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Çalışan',
          style: style.copyWith(color: Theme.of(context).accentColor),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    URL.getBinaryPhoto(path: user.photo.path),
                  ),
                  radius: MediaQuery.of(context).size.width * 0.25,
                ),
                Divider(),
                InformationLine('isim:', user.name),
                Divider(),
                InformationLine('Email:', user.email),
                Divider(),
                InformationLine(
                    'Rol:', user.role == "operator" ? "Çalışan" : "Yönetici"),
                Divider(),
                InformationLine(
                  'Oluşturulma Tarihi:',
                  DateFormat.yMd().format(user.createdAt),
                ),
                Divider(),
                InformationLine(
                  'Güncellenme Tarihi:',
                  DateFormat.yMd().format(user.updatedAt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
