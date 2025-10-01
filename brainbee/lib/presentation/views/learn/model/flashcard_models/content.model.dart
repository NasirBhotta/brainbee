// book_content_model.dart

class BookContentResponse {
  final String status;
  final BookContentData data;

  BookContentResponse({required this.status, required this.data});

  factory BookContentResponse.fromJson(Map<String, dynamic> json) {
    return BookContentResponse(
      status: json['status'] as String,
      data: BookContentData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}

class BookContentData {
  final String bookTitle;
  final List<BookChapter> chapters;

  BookContentData({required this.bookTitle, required this.chapters});

  factory BookContentData.fromJson(Map<String, dynamic> json) {
    return BookContentData(
      bookTitle: json['book_title'] as String,
      chapters:
          (json['chapters'] as List<dynamic>)
              .map((e) => BookChapter.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_title': bookTitle,
      'chapters': chapters.map((e) => e.toJson()).toList(),
    };
  }
}

class BookChapter {
  final String id;
  final String bookTitle;
  final int chapterNumber;
  final String chapterTitle;
  final String chapterIntro;
  final List<ChapterSection> sections;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookChapter({
    required this.id,
    required this.bookTitle,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.chapterIntro,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookChapter.fromJson(Map<String, dynamic> json) {
    return BookChapter(
      id: json['_id'] as String,
      bookTitle: json['book_title'] as String,
      chapterNumber: json['chapter_number'] as int,
      chapterTitle: json['chapter_title'] as String,
      chapterIntro: json['chapter_intro'] as String,
      sections:
          (json['sections'] as List<dynamic>)
              .map((e) => ChapterSection.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'book_title': bookTitle,
      'chapter_number': chapterNumber,
      'chapter_title': chapterTitle,
      'chapter_intro': chapterIntro,
      'sections': sections.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SubSection {
  final String subsectionTitle;
  final String content;

  SubSection({required this.subsectionTitle, required this.content});

  factory SubSection.fromJson(Map<String, dynamic> json) {
    return SubSection(
      subsectionTitle: json['subsection_title'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'subsection_title': subsectionTitle, 'content': content};
  }
}

class ChapterSection {
  final String sectionTitle;
  final String content;
  final List<SubSection> subsections;

  ChapterSection({
    required this.sectionTitle,
    required this.content,
    required this.subsections,
  });

  factory ChapterSection.fromJson(Map<String, dynamic> json) {
    var list = json['subsections'] as List? ?? [];
    List<SubSection> subsectionsList =
        list.map((e) => SubSection.fromJson(e)).toList();

    return ChapterSection(
      sectionTitle: json['section_title'] as String,
      content: json['content'] as String,
      subsections: subsectionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section_title': sectionTitle,
      'content': content,
      'subsections': subsections.map((e) => e.toJson()).toList(),
    };
  }
}

// Helper model for displaying chapter list
class ChapterListItem {
  final String id;
  final int chapterNumber;
  final String chapterTitle;
  final int sectionCount;

  ChapterListItem({
    required this.id,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.sectionCount,
  });

  factory ChapterListItem.fromBookChapter(BookChapter chapter) {
    return ChapterListItem(
      id: chapter.id,
      chapterNumber: chapter.chapterNumber,
      chapterTitle: chapter.chapterTitle,
      sectionCount: chapter.sections.length,
    );
  }
}
