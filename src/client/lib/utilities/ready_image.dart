import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';

import './image_convert.dart';

ImagePicker picker;
Future<String> selectImage({
  @required bool isCamera,
  bool highQuality = false,
  void Function(File) callback,
}) async {
  if (picker == null) picker = ImagePicker();
  String photoString;
  PickedFile pickedFile;
  if (highQuality) {
    if (isCamera)
      pickedFile = await picker.getImage(
        source: ImageSource.camera,
      );
    else
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
  } else {
    if (isCamera)
      pickedFile = await picker.getImage(
        source: ImageSource.camera,
        maxHeight: 480,
        maxWidth: 640,
      );
    else
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        maxHeight: 480,
        maxWidth: 640,
      );
  }

  if (pickedFile != null) {
    Uint8List photoBytes = await pickedFile.readAsBytes();
    Image photoImage = decodeImage(photoBytes);
    List<int> jpgPhoto = encodeJpg(photoImage);
    photoBytes = Uint8List.fromList(jpgPhoto);
    photoString = ImageConvert.base64String(photoBytes);
    if (callback != null) callback(File(pickedFile.path));
    return photoString;
  } else {
    return null;
  }
}
