// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mandir_app/screens/myFamilyList.dart';
import 'package:mandir_app/utils/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateAppScreen extends StatefulWidget {
  final String url;
  final String message;
  const UpdateAppScreen({
    Key? key,
    required this.url,
    required this.message,
  }) : super(key: key);

  @override
  State<UpdateAppScreen> createState() => _UpdateAppScreenState();
}

class _UpdateAppScreenState extends State<UpdateAppScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // FlutterDownloader.registerCallback((taskId, status, progress) async {
    //   if (status == DownloadTaskStatus.complete) {
    //     OpenResult result =
    //         await OpenFile.open('${directory.path}/$fileName.jpg');
    //     print(result.message);
    //   }
    // });
  }

  @override
  void _downloadApp() async {
    Directory? directory = Directory('/storage/emulated/0/Download');

    String downloadUrl = widget.url; // Replace with the actual URL
    // String fileName = 'Directory${DateTime.now().toString()}';
    String fileName = 'Directory';
    final taskId = await FlutterDownloader.enqueue(
      fileName: fileName,
      saveInPublicStorage: true,
      url: downloadUrl,
      savedDir: directory.path, // Replace with your desired download directory
      showNotification: true,
      openFileFromNotification: true,
    );
    await Permission.storage.request();
    // if (Permission.manageExternalStorage.isGranted == false) {
    //   await Permission.manageExternalStorage.request();
    // }

    // FlutterDownloader.registerCallback((taskId, status, progress) async {
    //   if (status == DownloadTaskStatus.complete) {
    //     OpenResult result =
    //         await OpenFile.open('${directory.path}/$fileName.jpg');
    //     print(result.message);
    //   }
    // });
    // OpenResult result =
    //     await OpenFile.open('/storage/emulated/0/Download/Directory.jpg');
    // print(result.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            nextScreenReplace(context, MyFamilyList(code: ''));
          },
          icon: const Icon(
            Icons.close,
          ),
        ),
        title: const Text(
          'Version Update',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(widget.message),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Download",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onPressed: () async {
                if (await Permission.notification.isGranted == false) {
                  await Permission.notification.request();
                }

                _downloadApp();
              },
            ),
          ],
        ),
      ),
    );
  }
}
