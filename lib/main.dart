import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import 'media_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AssetEntity> selectedAssets = [];

  Future<void> pickAssets(
      {required int maxCount, required RequestType requestType}) async {
    final result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MediaPicker(maxCount, requestType);
    }));
    if (result != null) {
      setState(() {
        selectedAssets = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                if (Platform.isAndroid) {
                  final androidInfo = await DeviceInfoPlugin().androidInfo;
                  if (androidInfo.version.sdkInt <= 32) {
                    // FileImagePicker().pickImage(context);
                    // Request media read and write permissions
                    var status = await Permission.storage.request();

                    if (status.isGranted) {
                      print("objsdect");
                      // Permission granted, you can access media storage
                    } else {
                      print("object");
                      await Permission.storage.request();
                      // Permission denied, handle it accordingly
                    }
                  } else {
                    /// use [Permissions.photos.status]
                    /// // FileImagePicker().pickImage(context);
                    // Request media read and write permissions
                    var status = await Permission.photos.request();

                    if (status.isGranted) {
                      print("objsdect");
                      // Permission granted, you can access media storage
                    } else {
                      print("object");
                      await Permission.photos.request();
                      // Permission denied, handle it accordingly
                    }
                  }
                }
              },
              icon: const Icon(Icons.perm_camera_mic))
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
              selectedAssets.length,
              (index) => AssetEntityImage(
                    selectedAssets[index],
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(1000),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          pickAssets(
            maxCount: 5,
            requestType: RequestType.image,
          );
        },
        child: const Icon(Icons.image),
      ),
    );
  }
}
