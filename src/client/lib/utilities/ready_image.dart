import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';

import './image_convert.dart';

ImagePicker picker;
Future<String> selectImage(bool isCamera) async {
  if (picker == null) picker = ImagePicker();
  String photoString;
  PickedFile pickedFile;
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
  if (pickedFile != null) {
    Uint8List photoBytes = await pickedFile.readAsBytes();
    Image photoImage = decodeImage(photoBytes);
    List<int> jpgPhoto = encodeJpg(photoImage);
    photoBytes = Uint8List.fromList(jpgPhoto);
    photoString = ImageConvert.base64String(photoBytes);
    return photoString;
  } else {
    return null;
  }
}
