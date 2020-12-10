// import 'package:dgcs_gps/utilities/show_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// import '../models/task.dart';
// import '../providers/tasks.dart';
// import '../utilities/ready_image.dart';
// import '../utilities/send_photo.dart';
// import '../widgets/images_widget.dart';
// import '../widgets/info_line.dart';
// import '../widgets/progress.dart';

// class EditTask extends StatefulWidget {
//   EditTask({
//     @required this.task,
//     @required this.token,
//   });
//   final Task task;
//   final String token;
//   @override
//   _EditTaskState createState() => _EditTaskState();
// }

// class _EditTaskState extends State<EditTask> {
//   final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
//   String _comment;
//   TextEditingController _controller = TextEditingController();
//   List<String> _photos = [];
//   final picker = ImagePicker();
//   bool _isLoading = false;
//   bool _isLoadingPhoto = false;

//   void _saveTask() async {
//     if (_photos.length != 0 && _controller.text != "") {
//       final result = await Diaglog.show(
//         ctx: context,
//         withCancel: true,
//         title: "Bilgilendirme",
//         content: "Görevi yalnızca bir kez güncelleyebilirsiniz. " +
//             "Güncenlenen görev bir daha güncellenemez." +
//             " Sadece görebilirsiniz." +
//             " Görevi güncellemek istediğinizden emin misiniz?",
//       );
//       if (result) {
//         setState(() {
//           _isLoading = true;
//         });
//         final photoIds = await postPhotos(photos: _photos);
//         _comment = _controller.text;
//         try {
//           await Provider.of<TaskProvider>(context, listen: false).updateTask(
//             id: widget.task.id,
//             comment: _comment,
//             photoIds: photoIds,
//             token: widget.token,
//           );
//         } catch (error) {
//           print(error);
//           await Diaglog.show(
//             ctx: context,
//             withCancel: false,
//             title: "Görev Güncellenemedi",
//             content: "Durum: ${error.toString()}",
//           );
//         } finally {
//           setState(() {
//             _isLoading = false;
//           });
//           Navigator.of(context).pop();
//         }
//       }
//     } else {
//       await Diaglog.show(
//         ctx: context,
//         withCancel: false,
//         title: "Yorum veya Resim Yüklemediniz.",
//         content: "Yorum ve resim yüklemeden görevi kaydedemezsiniz.\n" +
//             "Lütfen Önce yorum ve resim yükleyiniz.",
//       );
//     }
//   }

//   Widget createWidget(String identifier, String data) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         Expanded(
//           flex: 3,
//           child: Text(
//             identifier,
//             style: TextStyle(
//               fontSize: 20,
//             ),
//             textAlign: TextAlign.left,
//           ),
//         ),
//         Expanded(
//           flex: 5,
//           child: Text(
//             data,
//             style: TextStyle(
//               fontSize: 20,
//             ),
//             textAlign: TextAlign.left,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _createPhotoGalery() {
//     return Container(
//         width: double.infinity,
//         height: MediaQuery.of(context).size.height * 0.3,
//         child: ImagesWidget(
//           base64ImagesSource: _photos,
//           isRadius: false,
//           isCard: false,
//         ));
//   }

//   void _iconOnTab(bool isCamera) async {
//     setState(() {
//       _isLoading = true;
//       _isLoadingPhoto = true;
//     });
//     final photo = await selectImage(
//       isCamera,
//     );
//     setState(() {
//       _isLoading = false;
//       _isLoadingPhoto = false;
//       if (photo != null) {
//         _photos.add(photo);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Görev Gerçekleştir',
//           style: style.copyWith(color: Theme.of(context).accentColor),
//         ),
//       ),
//       body: SafeArea(
//         child: (_isLoading)
//             ? Progress(_isLoadingPhoto
//                 ? "Fotoğraf Hazırlanıyor..."
//                 : 'Güncelleniyor...')
//             : Container(
//                 padding: EdgeInsets.all(16),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       if (_photos.length != 0) _createPhotoGalery(),
//                       if (_photos.length == 0)
//                         Container(
//                           width: MediaQuery.of(context).size.width * 0.6,
//                           child: Image.asset('assets/images/no_image.jpg'),
//                         ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: MediaQuery.of(context).size.width * 0.20,
//                             child: GestureDetector(
//                               onTap: () => _iconOnTab(false),
//                               child: FittedBox(
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(bottom: 2.0),
//                                   child: Icon(Icons.photo),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: MediaQuery.of(context).size.width * 0.2,
//                             child: GestureDetector(
//                               onTap: () => _iconOnTab(true),
//                               child: FittedBox(
//                                 child: Icon(Icons.camera_alt),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       TextFormField(
//                         decoration:
//                             InputDecoration(labelText: 'Operatör Yorumu'),
//                         maxLines: 3,
//                         textInputAction: TextInputAction.done,
//                         controller: _controller,
//                       ),
//                       Divider(),
//                       InformationLine('Görev ismi:', widget.task.name),
//                       Divider(),
//                       InformationLine(
//                         'Görev numarası:',
//                         widget.task.id.toString(),
//                       ),
//                       Divider(),
//                       InformationLine(
//                         'Açıklama:',
//                         widget.task.description,
//                       ),
//                       Divider(),
//                       InformationLine(
//                         'Oluşturulma Tarih:',
//                         DateFormat.yMd().format(
//                           widget.task.createdAt,
//                         ),
//                       ),
//                       Divider(),
//                       InformationLine(
//                         'Lokasyon:',
//                         '${widget.task.location.latitude.toStringAsFixed(4)}' +
//                             ' ${widget.task.location.longitude.toStringAsFixed(4)}',
//                       ),
//                       if (widget.task.isComplete) Divider(),
//                       if (widget.task.isComplete)
//                         InformationLine(
//                           'Tamamlanma Tarih:',
//                           DateFormat.yMd().format(widget.task.updatedAt),
//                         ),
//                       Divider(),
//                       InformationLine('Görev:',
//                           'Tamamlan${widget.task.isComplete ? 'dı' : 'madı'}.'),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//       floatingActionButton: FloatingActionButton(
//           backgroundColor: Theme.of(context).primaryColor,
//           child: Icon(
//             Icons.send,
//             color: Theme.of(context).accentColor,
//           ),
//           onPressed: () {
//             _saveTask();
//           }),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }
