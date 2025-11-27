// models/book_model.dart
class BookModel {
  final String id;
  final String bookTitle;
  final String? subject;
  final String? author;
  final String? coverImage;
  final int totalPages;
  final int totalQuizzes;
  final List<String> chapters;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookModel({
    required this.id,
    required this.bookTitle,
    this.subject,
    this.author,
    this.coverImage,
    this.totalPages = 0,
    this.totalQuizzes = 0,
    required this.chapters,
    this.createdAt,
    this.updatedAt,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookTitle: json['book_title'] ?? json['title'] ?? '',
      subject: json['subject'],
      author: json['author'],
      coverImage: json['coverImage'],
      totalPages: json['totalPages'] ?? 0,
      totalQuizzes: json['totalQuizzes'] ?? 0,
      chapters:
          json['chapters'] != null
              ? List<String>.from(json['chapters'].map((x) => x.toString()))
              : [],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_title': bookTitle,
      'subject': subject,
      'author': author,
      'coverImage': coverImage,
      'totalPages': totalPages,
      'totalQuizzes': totalQuizzes,
      'chapters': chapters,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// models/grade_books_response.dart
class GradeBooksResponse {
  final int grade;
  final List<String> subjects;
  final int totalSubjects;
  final Map<String, List<BookModel>> booksBySubject;
  final List<BookModel> books;
  final int totalBooks;

  GradeBooksResponse({
    required this.grade,
    required this.subjects,
    required this.totalSubjects,
    required this.booksBySubject,
    required this.books,
    required this.totalBooks,
  });

  factory GradeBooksResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    // Parse booksBySubject
    Map<String, List<BookModel>> booksBySubject = {};
    if (data['booksBySubject'] != null) {
      (data['booksBySubject'] as Map<String, dynamic>).forEach((key, value) {
        booksBySubject[key] =
            (value as List).map((book) => BookModel.fromJson(book)).toList();
      });
    }

    // Parse books array
    List<BookModel> books = [];
    if (data['books'] != null) {
      books =
          (data['books'] as List)
              .map((book) => BookModel.fromJson(book))
              .toList();
    }

    return GradeBooksResponse(
      grade: data['grade'] ?? 0,
      subjects:
          data['subjects'] != null ? List<String>.from(data['subjects']) : [],
      totalSubjects: data['totalSubjects'] ?? 0,
      booksBySubject: booksBySubject,
      books: books,
      totalBooks: data['totalBooks'] ?? 0,
    );
  }
}
