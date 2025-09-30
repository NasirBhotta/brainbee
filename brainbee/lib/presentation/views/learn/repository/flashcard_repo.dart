import 'package:brainbee/presentation/views/learn/model/flashcard_models/content.model.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/flashcard_model.dart';

abstract class FlashCardContentRepository {
  /// Fetches all chapters for a specific subject and grade
  Future<BookContentData> getBookChapters({
    required String subject,
    required int grade,
  });

  /// Fetches details of a specific chapter by chapter number
  Future<BookChapter> getChapterDetails({
    required String subject,
    required int grade,
    required int chapterNumber,
  });

  /// Fetches chapter details by chapter ID
  Future<BookChapter> getChapterById(String chapterId);

  Future<List<Flashcard>> getFlashcardsForBook({
    required String studentId,
    required String bookName,
  });

  Future<String> generateFlashcards({
    required String studentId,
    required String subject,
    required String topicQuery,
  });
}
