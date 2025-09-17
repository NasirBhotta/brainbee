import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AuthApiService {
  static const String baseUrl = "http://10.0.2.2:5000";
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<http.Response> getProfile(String token) async {
    return await http
        .get(
          Uri.parse("$baseUrl/api/auth/get-profile"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .timeout(timeoutDuration);
  }

  Future<http.Response> updateProfileImage(File image, String token) async {
    final uri = Uri.parse("$baseUrl/api/auth/update-profile-pic");
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // Determine MIME type from file extension
    String fileExtension = image.path.split('.').last.toLowerCase();
    MediaType contentType = _getContentType(fileExtension);

    request.files.add(
      await http.MultipartFile.fromPath(
        'profileImage',
        image.path,
        contentType: contentType,
      ),
    );

    var streamedResponse = await request.send().timeout(timeoutDuration);
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateProfileData({
    required String firstName,
    required String lastName,
    required String address,
    required String phoneNumber,
    required String token,
  }) async {
    return await http
        .post(
          Uri.parse("$baseUrl/api/auth/update-profile"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "firstName": firstName,
            "lastName": lastName,
            "address": address,
            "phone": phoneNumber,
          }),
        )
        .timeout(timeoutDuration);
  }

  MediaType _getContentType(String fileExtension) {
    switch (fileExtension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
