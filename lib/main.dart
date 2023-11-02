import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager_package/service/media_service.dart';

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
  List<File?>? selectedAssets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
              onPressed: () async {
                selectedAssets =
                    await MediaService().pickImage(context, maxCount: 1);
                setState(() {});
              },
              child: const Text("Pick Image")),
          const SizedBox(
            height: 20,
          ),
          if (selectedAssets != null && selectedAssets!.isNotEmpty)
            Image.file(selectedAssets![0]!)
        ],
      ),
    ));
  }
}
