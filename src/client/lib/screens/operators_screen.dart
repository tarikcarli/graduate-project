// import 'package:dgcs_gps/screens/single_operator_screen.dart';
// import 'package:dgcs_gps/widgets/user_list_item.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../providers/users.dart';

// class Operators extends StatefulWidget {
//   @override
//   _OperatorsState createState() => _OperatorsState();
// }

// class _OperatorsState extends State<Operators> {
//   final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
//   UserProvider _userProvider;
//   @override
//   void initState() {
//     super.initState();
//     _userProvider = Provider.of<UserProvider>(
//       context,
//       listen: false,
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final operators = _userProvider.operators;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Operatörler',
//           style: style.copyWith(
//             color: Theme.of(context).accentColor,
//           ),
//         ),
//       ),
//       body: Center(
//         child: operators.length > 0
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: operators.length,
//                       itemBuilder: (ctx, i) => Column(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) {
//                                     return SingleOperatorScreen(
//                                         operatorModel: operators[i]);
//                                   },
//                                 ),
//                               );
//                             },
//                             child: UserListItem(
//                               user: operators[i],
//                             ),
//                           ),
//                           Divider(),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               )
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         'Hiç Göreviniz Yok!',
//                         style: TextStyle(fontSize: 20.0),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
