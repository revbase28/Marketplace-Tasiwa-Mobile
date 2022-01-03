import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<String?> pickImageToBase64() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? _image = await _picker.pickImage(source: ImageSource.gallery);

  if (_image != null) {
    final _imageInBase64 = base64Encode(File(_image.path).readAsBytesSync());
    return _imageInBase64;
  } else {
    return null;
  }
}
