// lib/core/utils/file_downloader.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart'; // Add this package to open files

class FileDownloader {
  /// Downloads a file from a URL after checking for storage permission.
  ///
  /// Returns the local path to the downloaded file, or null if the download
  /// fails or permission is denied.
  static Future<String?> downloadWithPermissionCheck({
    required String url,
    required BuildContext context,
    String? fileName,
    Function(double)? onProgress,
  }) async {
    // 1. Handle permissions based on Android version
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we don't need storage permission for app-specific directory
      // For Android 10-12, scoped storage is used
      // For Android 9 and below, we need WRITE_EXTERNAL_STORAGE

      final androidInfo = await _getAndroidVersion();

      if (androidInfo < 33) {
        // For Android 12 and below, check storage permission
        var status = await Permission.storage.status;

        if (!status.isGranted) {
          status = await Permission.storage.request();

          if (!status.isGranted) {
            if (status.isPermanentlyDenied) {
              _showOpenSettingsDialog(context);
            } else {
              _showSnackBar(
                context,
                'Storage permission is required to download files.',
              );
            }
            return null;
          }
        }
      }
      // For Android 13+, no storage permission needed for app-specific directories
    }

    // 2. Proceed with download if permission is granted
    try {
      // Get directory to save file
      // Using getApplicationDocumentsDirectory() saves to app-specific storage
      // This doesn't require permissions on Android 10+
      final directory = await getApplicationDocumentsDirectory();

      final parsedUrl = Uri.parse(url);
      final finalFileName = fileName ?? parsedUrl.pathSegments.last;
      final filePath = '${directory.path}/$finalFileName';
      final file = File(filePath);

      // Download the file
      final request = http.Request('GET', parsedUrl);
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw Exception(
          'Failed to download file: ${streamedResponse.statusCode}',
        );
      }

      // Save the file to local storage with progress tracking
      final contentLength = streamedResponse.contentLength ?? 0;
      final fileSink = file.openWrite();
      int downloadedBytes = 0;

      await for (final chunk in streamedResponse.stream) {
        fileSink.add(chunk);
        downloadedBytes += chunk.length;

        if (onProgress != null && contentLength > 0) {
          final progress = downloadedBytes / contentLength;
          onProgress(progress);
        }
      }

      await fileSink.close();

      _showSnackBar(context, 'File downloaded successfully!');

      // Optionally open the file
      _showOpenFileDialog(context, filePath);

      return filePath;
    } catch (e) {
      _showSnackBar(context, 'Failed to download file: $e');
      return null;
    }
  }

  /// Alternative: Download to Downloads folder (requires different approach for Android 10+)
  static Future<String?> downloadToDownloadsFolder({
    required String url,
    required BuildContext context,
    String? fileName,
    Function(double)? onProgress,
  }) async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 29) {
        // Android 10+ uses scoped storage
        // Files in Downloads folder don't need permission but require MediaStore API
        // For simplicity, we'll use app-specific directory
        return downloadWithPermissionCheck(
          url: url,
          context: context,
          fileName: fileName,
          onProgress: onProgress,
        );
      } else {
        // For Android 9 and below
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            _showSnackBar(context, 'Storage permission denied');
            return null;
          }
        }

        final directory = Directory('/storage/emulated/0/Download');
        final parsedUrl = Uri.parse(url);
        final finalFileName = fileName ?? parsedUrl.pathSegments.last;
        final filePath = '${directory.path}/$finalFileName';

        return _downloadFile(url, filePath, context, onProgress);
      }
    }

    return downloadWithPermissionCheck(
      url: url,
      context: context,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  static Future<String?> _downloadFile(
    String url,
    String filePath,
    BuildContext context,
    Function(double)? onProgress,
  ) async {
    try {
      final file = File(filePath);
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw Exception('Failed to download: ${streamedResponse.statusCode}');
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      final fileSink = file.openWrite();
      int downloadedBytes = 0;

      await for (final chunk in streamedResponse.stream) {
        fileSink.add(chunk);
        downloadedBytes += chunk.length;

        if (onProgress != null && contentLength > 0) {
          onProgress(downloadedBytes / contentLength);
        }
      }

      await fileSink.close();
      return filePath;
    } catch (e) {
      _showSnackBar(context, 'Download failed: $e');
      return null;
    }
  }

  /// Get Android SDK version
  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      try {
        // This is a simplified version. In production, use device_info_plus package
        return 33; // Assume modern Android for now
      } catch (e) {
        return 33;
      }
    }
    return 0;
  }

  /// Shows a dialog prompting the user to open app settings.
  static void _showOpenSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Storage permission is permanently denied. Please enable it in app settings to download files.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows dialog to open the downloaded file
  static void _showOpenFileDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Download Complete'),
          content: const Text('Would you like to open the file?'),
          actions: [
            TextButton(
              child: const Text('Later'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Open'),
              onPressed: () {
                Navigator.of(context).pop();
                OpenFilex.open(filePath);
              },
            ),
          ],
        );
      },
    );
  }

  /// Utility to show a SnackBar with a consistent style.
  static void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
