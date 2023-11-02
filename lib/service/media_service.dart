import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import 'media_picker.dart';

class MediaService {
  Future<List<AssetPathEntity>> loadAlbums(requestType) async {
    var permission = await PhotoManager.requestPermissionExtend();
    List<AssetPathEntity> albumList = [];
    if (permission.isAuth == true) {
      albumList = await PhotoManager.getAssetPathList(
        type: requestType,
      );
    } else {
      PhotoManager.openSetting();
    }
    return albumList;
  }

  Future loadAssets(AssetPathEntity selectedAlbum) async {
    List<AssetEntity> assetsList = await selectedAlbum.getAssetListRange(
        start: 0, end: await selectedAlbum.assetCountAsync);
    return assetsList;
  }

  Future<List<File?>?> pickImage(context,
      {int maxCount = 1, RequestType requestType = RequestType.image}) async {
    bool isHasPermission = await checkPermission();
    List<File?>? imageFiles = [];
    if (isHasPermission) {
      final files =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MediaPicker(maxCount, requestType);
      }));

      if (files != null) {
        imageFiles = files;
      } else {
        imageFiles = null;
        Logger().e(files);
      }
    } else {
      Logger().e("You Didnt Has Permision");
    }
    return imageFiles;
  }

  Future<bool> checkPermission() async {
    bool isGranted = false;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        var status = await Permission.storage.request();

        if (status.isGranted) {
          isGranted = true;
        } else {
          isGranted = false;
        }
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
      } else {
        var status = await Permission.photos.request();

        if (status.isGranted) {
          isGranted = true;
        } else {
          isGranted = false;
        }
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
      }
    } else {
      var status = await Permission.photos.request();

      if (status.isGranted) {
        isGranted = true;
      } else {
        isGranted = false;
      }
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }

    return isGranted;
  }
}
