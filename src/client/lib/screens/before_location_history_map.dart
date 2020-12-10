// import 'package:flutter/material.dart';

// import '../models/user.dart';
// import '../widgets/before_history_list_item.dart';

// class BeforeLocationHistoryMap extends StatefulWidget {
//   BeforeLocationHistoryMap({
//     this.allOperator,
//   });
//   final List<User> allOperator;

//   @override
//   _BeforeLocationHistoryMapState createState() =>
//       _BeforeLocationHistoryMapState();
// }

// class _BeforeLocationHistoryMapState extends State<BeforeLocationHistoryMap> {
//   final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
//   int duration = 24;
//   void selectProcess(int value) async {
//     setState(() {
//       duration = value;
//     });
//   }

//   Widget createPopupItem(String name) {
//     return Text(
//       name,
//       style: style.copyWith(
//         color: duration == int.parse(name.split(' ')[0]) ? Colors.blue : null,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Operatörler',
//           style: style.copyWith(
//             color: Theme.of(context).accentColor,
//           ),
//         ),
//         actions: [
//           PopupMenuButton<int>(
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.history,
//                 ),
//                 SizedBox(
//                   width: 5,
//                 ),
//                 Text(
//                   'Süre',
//                   style: style,
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//               ],
//             ),
//             onSelected: selectProcess,
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
//               PopupMenuItem<int>(
//                 value: 1,
//                 child: createPopupItem('1 Saat'),
//               ),
//               PopupMenuItem<int>(
//                 value: 2,
//                 child: createPopupItem('2 Saat'),
//               ),
//               PopupMenuItem<int>(
//                 value: 4,
//                 child: createPopupItem('4 Saat'),
//               ),
//               PopupMenuItem<int>(
//                 value: 8,
//                 child: createPopupItem('8 Saat'),
//               ),
//               PopupMenuItem<int>(
//                 value: 12,
//                 child: createPopupItem('12 Saat'),
//               ),
//               PopupMenuItem<int>(
//                 value: 24,
//                 child: createPopupItem('24 Saat'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: widget.allOperator.length == 0
//           ? Center(
//               child: Text(
//                 "Hiç Operatörünüz yok!",
//                 style: style,
//               ),
//             )
//           : ListView.builder(
//               itemCount: widget.allOperator.length,
//               itemBuilder: (BuildContext ctx, int index) {
//                 return BeforeHistoryListItem(
//                   user: widget.allOperator[index],
//                   duration: duration,
//                 );
//               }),
//     );
//   }
// }
