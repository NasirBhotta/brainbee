import 'dart:convert';

import 'package:brainbee/presentation/views/learn/model/flashcard_models/content.model.dart';
import 'package:brainbee/presentation/views/learn/repository/flashcard_repo.dart';
import 'package:brainbee/presentation/views/learn/services/flashcard_api_service.dart';

class FlashCardContentRepositoryImpl implements FlashCardContentRepository {
  final FlashCardContentApiService apiService;

  FlashCardContentRepositoryImpl({required this.apiService});

  @override
  Future<BookContentData> getBookChapters({
    required String subject,
    required int grade,
  }) async {
    try {
      final response = await apiService.getBookChapters(
        subject: subject,
        grade: grade,
      );

      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final bookContentResponse = BookContentResponse.fromJson(jsonData);

      return bookContentResponse.data;
    } on FlashCardContentApiException catch (e) {
      throw Exception('Failed to load chapters: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load chapters: $e');
    }
  }

  @override
  Future<BookChapter> getChapterDetails({
    required String subject,
    required int grade,
    required int chapterNumber,
  }) async {
    try {
      final response = await apiService.getChapterDetails(
        subject: subject,
        grade: grade,
        chapterNumber: chapterNumber,
      );

      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      // Assuming the API returns the chapter directly in data
      if (jsonData['status'] == 'success' && jsonData['data'] != null) {
        return BookChapter.fromJson(jsonData['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } on FlashCardContentApiException catch (e) {
      throw Exception('Failed to load chapter details: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load chapter details: $e');
    }
  }

  @override
  Future<BookChapter> getChapterById(String chapterId) async {
    try {
      final response = await apiService.getChapterById(chapterId);

      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'success' && jsonData['data'] != null) {
        return BookChapter.fromJson(jsonData['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } on FlashCardContentApiException catch (e) {
      throw Exception('Failed to load chapter: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load chapter: $e');
    }
  }
}
