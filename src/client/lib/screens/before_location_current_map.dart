// import 'package:flutter/material.dart';

// import '../models/user.dart';
// import '../widgets/before_current_list_item.dart';

// class BeforeLocationCurrentMap extends StatelessWidget {
//   final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
//   BeforeLocationCurrentMap({
//     @required this.allOperator,
//   });
//   final List<User> allOperator;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Operatörler',
//           style: style.copyWith(color: Theme.of(context).accentColor),
//         ),
//       ),
//       body: allOperator.length == 0
//           ? Center(
//               child: Text(
//                 "Hiç Operatörünüz yok!",
//                 style: style,
//               ),
//             )
//           : ListView.builder(
//               itemCount: allOperator.length,
//               itemBuilder: (BuildContext ctx, int index) {
//                 if (index == 0)
//                   return Column(
//                     children: [
//                       BeforeCurrentListItem(
//                         allUser: allOperator,
//                         user: null,
//                       ),
//                       BeforeCurrentListItem(
//                         user: allOperator[0],
//                         allUser: null,
//                       ),
//                     ],
//                   );
//                 else
//                   return BeforeCurrentListItem(
//                     user: allOperator[index],
//                     allUser: null,
//                   );
//               }),
//     );
//   }
// }
