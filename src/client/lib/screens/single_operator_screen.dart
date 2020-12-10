// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../models/user.dart';
// import '../widgets/image_widget.dart';
// import '../widgets/info_line.dart';

// class SingleOperatorScreen extends StatelessWidget {
//   final User operatorModel;
//   SingleOperatorScreen({this.operatorModel});

//   final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Operatör',
//           style: style.copyWith(color: Theme.of(context).accentColor),
//         ),
//       ),
//       body: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.5,
//                   height: MediaQuery.of(context).size.height * 0.5,
//                   child: FittedBox(
//                     child: ImageWidget(
//                       isCard: false,
//                       base64ImageSource: operatorModel.photo.photo,
//                     ),
//                   ),
//                 ),
//                 Divider(),
//                 InformationLine('isim:', operatorModel.firstName),
//                 Divider(),
//                 InformationLine('Soyisim:', operatorModel.lastName),
//                 Divider(),
//                 InformationLine('Telefon Numarası:', operatorModel.phoneNumber),
//                 Divider(),
//                 InformationLine(
//                   'Oluşturulma Tarihi:',
//                   DateFormat.yMd().format(operatorModel.createdAt),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
