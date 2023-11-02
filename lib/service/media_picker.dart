import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_package/service/media_service.dart';
import 'package:shimmer/shimmer.dart';

class MediaPicker extends StatefulWidget {
  final int maxCount;
  final RequestType requestType;

  const MediaPicker(this.maxCount, this.requestType, {super.key});

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  bool isAlbumLoading = true;
  bool isAssetsLoading = true;
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
        isAlbumLoading = false;
      });
      MediaService().loadAssets(selectedAlbum!).then((value) {
        setState(() {
          assetList = value;
          isAssetsLoading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const BackButton(),
                  const Spacer(),
                  const Text(
                    "Image Picker",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  selectedList.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            Navigator.pop(context, selectedFile);
                          },
                          child: Chip(
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 0,
                                  ),
                                  borderRadius: BorderRadius.circular(20)),
                              label: Text("Ok (${selectedList.length})",
                                  style: const TextStyle(color: Colors.white))),
                        )
                      : const SizedBox(),
                ],
              ),
              const Divider(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: !isAlbumLoading
                    ? Row(
                        children: List.generate(
                            albumList.length,
                            (index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAlbum = albumList[index];
                                    isAssetsLoading = true;
                                  });
                                  MediaService()
                                      .loadAssets(selectedAlbum!)
                                      .then((value) {
                                    setState(() {
                                      assetList = value;
                                      isAssetsLoading = false;
                                    });
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 2),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: selectedAlbum == albumList[index]
                                            ? Colors.black
                                            : Colors.black54,
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    height: 30,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          getAlbumImage(albumList[index]),
                                          width: 25,
                                          height: 25,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          albumList[index].name,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      )
                    : Row(
                        children: List.generate(
                            5,
                            (index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 2),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade700,
                                    highlightColor: Colors.grey.shade900,
                                    child: Container(
                                      height: 30,
                                      width: 100,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                    ),
                                  ),
                                )),
                      ),
              ),
              const Divider(),
              isAssetsLoading
                  ? Expanded(
                      child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: 20,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2),
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                              baseColor: Colors.grey.shade600,
                              highlightColor: Colors.grey.shade700,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: Colors.grey,
                                ),
                              ));
                        },
                      ),
                    ))
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: assetList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2),
                          itemBuilder: (context, index) {
                            AssetEntity assetEntity = assetList[index];
                            return assetWidget(assetEntity, index);
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ));
  }

  Widget assetWidget(AssetEntity assetEntity, int index) => Stack(
        children: [
          Positioned.fill(
              child: GestureDetector(
            onTap: () async {
              await assetEntity.file.then((value) {
                if (widget.maxCount == 1) {
                  Navigator.pop(context, [value]);
                } else {
                  if (selectedList.contains(assetEntity)) {
                    setState(() {
                      selectedList.remove(assetEntity);
                      selectedFile.remove(value);
                    });
                  } else {
                    setState(() {
                      if (widget.maxCount > selectedList.length) {
                        selectedList.add(assetEntity);
                        selectedFile.add(value);
                      }
                    });
                  }
                }
              });
            },
            child: Padding(
              padding:
                  EdgeInsets.all(selectedList.contains(assetEntity) ? 4 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AssetEntityImage(
                  assetEntity,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(500),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                ),
              ),
            ),
          )),
          selectedList.contains(assetEntity)
              ? Positioned(
                  top: 5,
                  right: 5,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blue,
                    child: Text(
                      "${selectedList.indexOf(assetList[index]) + 1}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ))
              : const SizedBox()
        ],
      );

  String getAlbumImage(AssetPathEntity album) {
    String an = album.name.toLowerCase();
    String path = "assets/icons/album_icons/";
    if (an.contains("recent")) {
      return "${path}recent.png";
    } else if (an.contains("camera") || an.contains("dcim")) {
      return "${path}camera.png";
    } else if (an.contains("download")) {
      return "${path}download.png";
    } else if (an.contains("fav")) {
      return "${path}fav.png";
    } else if (an.contains("facebook")) {
      return "${path}fb.png";
    } else if (an.contains("insta")) {
      return "${path}instagram.png";
    } else if (an.contains("screen")) {
      return "${path}screen_shots.png";
    } else if (an.contains("whatsapp")) {
      return "${path}whatsapp.png";
    } else {
      return "${path}album.png";
    }
  }
}
