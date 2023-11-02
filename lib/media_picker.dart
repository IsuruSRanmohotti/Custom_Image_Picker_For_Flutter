import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_package/service/media_service.dart';

class MediaPicker extends StatefulWidget {
  final int maxCount;
  final RequestType requestType;

  const MediaPicker(this.maxCount, this.requestType, {super.key});

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  List<AssetEntity> selectedList = [];
  List<File?> selectedFile = [];

  @override
  void initState() {
    MediaService().loadAlbums(widget.requestType).then((value) {
      setState(() {
        albumList = value;
        selectedAlbum = value[0];
      });
      MediaService().loadAssets(selectedAlbum!).then((value) {
        setState(() {
          assetList = value;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context, selectedList);
                },
                icon: const Icon(Icons.abc))
          ],
          backgroundColor: Colors.blue,
          title: DropdownButton<AssetPathEntity>(
              items: albumList.map<DropdownMenuItem<AssetPathEntity>>((album) {
                return DropdownMenuItem(
                    value: album,
                    child: Text(
                      "${album.name} (${album.assetCount})",
                      style: const TextStyle(color: Colors.black),
                    ));
              }).toList(),
              onChanged: (AssetPathEntity? val) {
                setState(() {
                  selectedAlbum = val;
                });
                MediaService().loadAssets(selectedAlbum!).then((value) {
                  setState(() {
                    assetList = value;
                  });
                });
              }),
        ),
        body: assetList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: assetList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  AssetEntity assetEntity = assetList[index];
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: assetWidget(assetEntity, index),
                  );
                },
              ));
  }

  Widget assetWidget(AssetEntity assetEntity, int index) => Stack(
        children: [
          Positioned.fill(
              child: GestureDetector(
            onTap: () async {
              File? file = await assetEntity.file;
              if (selectedList.contains(assetEntity)) {
                
                setState(() {
                  selectedList.remove(assetEntity);
                  selectedFile.remove(file);
                });
              } else {
                setState(() {
                  if (widget.maxCount > selectedList.length) {
                    selectedList.add(assetEntity);
                    selectedFile.add(file);
                    assetEntity.file.then((value) {
                      String? path = value!.path;
                      Logger().f(path);
                    });
                  }
                });
              }
            },
            child: Padding(
              padding:
                  EdgeInsets.all(selectedList.contains(assetEntity) ? 8 : 0),
              child: AssetEntityImage(
                assetEntity,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(250),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            ),
          )),
          selectedList.contains(assetEntity)
              ? Align(
                  alignment: Alignment.center,
                  child: Text("${selectedList.indexOf(assetEntity) + 1}"),
                )
              : const SizedBox()
        ],
      );
}
