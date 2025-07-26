import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';

class RealFileService {
  static final Dio _dio = Dio();
  static final ImagePicker _imagePicker = ImagePicker();

  // Request necessary permissions
  static Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> permissions =
        await [
          Permission.storage,
          Permission.manageExternalStorage,
          Permission.camera,
          Permission.photos,
        ].request();

    return permissions.values.every(
      (status) =>
          status == PermissionStatus.granted ||
          status == PermissionStatus.limited,
    );
  }

  // Pick files from device
  static Future<List<File>?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
        withData: false,
        withReadStream: true,
      );

      if (result != null) {
        return result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }
      return null;
    } catch (e) {
      debugPrint('Error picking files: $e');
      return null;
    }
  }

  // Pick image from camera or gallery
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Download file from URL
  static Future<File?> downloadFile({
    required String url,
    required String fileName,
    String? customPath,
    Function(double)? onProgress,
  }) async {
    try {
      Directory directory;
      if (customPath != null) {
        directory = Directory(customPath);
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final String filePath = '${directory.path}/$fileName';

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      final File file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }

  // Save file to device storage
  static Future<File?> saveFile({
    required Uint8List data,
    required String fileName,
    String? customPath,
  }) async {
    try {
      Directory directory;
      if (customPath != null) {
        directory = Directory(customPath);
      } else {
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final String filePath = '${directory.path}/$fileName';
      final File file = File(filePath);

      await file.writeAsBytes(data);
      return file;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  // Read file content
  static Future<String?> readFileAsString(File file) async {
    try {
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading file: $e');
      return null;
    }
  }

  // Read file as bytes
  static Future<Uint8List?> readFileAsBytes(File file) async {
    try {
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading file as bytes: $e');
      return null;
    }
  }

  // Open file with default app
  static Future<bool> openFile(File file) async {
    try {
      if (await file.exists()) {
        final result = await OpenFile.open(file.path);
        return result.type == ResultType.done;
      }
      return false;
    } catch (e) {
      debugPrint('Error opening file: $e');
      return false;
    }
  }

  // Share file
  static Future<bool> shareFile(File file, {String? subject}) async {
    try {
      if (await file.exists()) {
        await Share.shareXFiles([XFile(file.path)], subject: subject);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sharing file: $e');
      return false;
    }
  }

  // Delete file
  static Future<bool> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  // Get file size
  static Future<int?> getFileSize(File file) async {
    try {
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return null;
    }
  }

  // Get file extension
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  // Check if file is image
  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Check if file is document
  static bool isDocumentFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'].contains(extension);
  }

  // Check if file is video
  static bool isVideoFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv'].contains(extension);
  }

  // Get file icon based on extension
  static IconData getFileIcon(String filePath) {
    if (isImageFile(filePath)) return Icons.image;
    if (isDocumentFile(filePath)) return Icons.description;
    if (isVideoFile(filePath)) return Icons.video_file;

    final extension = getFileExtension(filePath);
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file;
      case 'xlsx':
      case 'xls':
        return Icons.table_chart;
      case 'pptx':
      case 'ppt':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Format file size to human readable
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Create app-specific directory
  static Future<Directory?> createAppDirectory(String folderName) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory newDir = Directory('${appDir.path}/$folderName');

      if (!await newDir.exists()) {
        await newDir.create(recursive: true);
      }

      return newDir;
    } catch (e) {
      debugPrint('Error creating directory: $e');
      return null;
    }
  }

  // Upload file to server (you'll need to implement your server endpoint)
  static Future<String?> uploadFile({
    required File file,
    required String uploadUrl,
    Map<String, dynamic>? additionalData,
    Function(double)? onProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        ...?additionalData,
      });

      Response response = await _dio.post(
        uploadUrl,
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        // Return the file URL or ID from server response
        return response.data['fileUrl'] ?? response.data['fileId'];
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }
}
