import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class FileImagePicker {
  ImagePicker picker = ImagePicker();

  Future<File?> pickImage(BuildContext context) async {
    final file =
        await picker.pickImage(source: ImageSource.gallery).then((value) async {
      if (value != null) {
        Logger().f(value.path);
        File? croppedImg = await cropImage(context, File(value.path));
        return croppedImg;
      } else {
        Logger().e("Try Again");
        return null;
      }
    });
    return file;
  }

  Future<File?> cropImage(BuildContext context, File file) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressFormat: ImageCompressFormat.jpg,
      maxHeight: 512,
      maxWidth: 512,
      compressQuality: 60,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if (croppedFile != null) {
      Logger().e("cropped");
      return File(croppedFile.path);
    } else {
      return null;
    }
  }
}
