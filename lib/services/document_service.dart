import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class DocumentService {
  final Dio _dio = Dio();

  Future<String?> downloadDocument(
      String url, String fileName, BuildContext context) async {
    try {
      // Request permission
      if (!(await _requestStoragePermission())) {
        _showMessage(context, "Storage permission denied.");
        return null;
      }

      // Get the Downloads folder
      Directory? directory =
          Directory('/storage/emulated/0/Download'); // Public Downloads folder
      if (!await directory.exists()) {
        directory =
            await getExternalStorageDirectory(); // Fallback: app directory
      }

      String filePath = "${directory!.path}/$fileName";

      // Download file
      _showMessage(context, "Downloading...");
      await _dio.download(url, filePath);

      _showMessage(context, "Download Complete! File saved in Downloads.");
      return filePath;
    } catch (e) {
      _showMessage(context, "Download Failed: $e");
      return null;
    }
  }

  Future<void> openDocument(String filePath) async {
    OpenFile.open(filePath);
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) return true;

    var manageStatus = await Permission.manageExternalStorage.request();
    return manageStatus.isGranted;
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
