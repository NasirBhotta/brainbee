// UI/select_books_screen.dart
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/settings/bloc/setting_bloc.dart';
import 'package:brainbee/presentation/views/settings/model/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectSubjectsScreen extends StatefulWidget {
  final int selectedGrade;
  final StudentModel student;

  const SelectSubjectsScreen({
    super.key,
    required this.student,
    required this.selectedGrade,
  });

  @override
  State<SelectSubjectsScreen> createState() => _SelectSubjectsScreenState();
}

class _SelectSubjectsScreenState extends State<SelectSubjectsScreen> {
  List<String> selectedBookIds = [];
  bool isLoading = false;
  bool isInitialized = false;
  int? selectedGrade;

  // Icon mapping for subjects
  final Map<String, IconData> subjectIcons = {
    'Mathematics': Icons.calculate,
    'Physics': Icons.science,
    'Chemistry': Icons.biotech,
    'Biology': Icons.local_florist,
    'English': Icons.book,
    'History': Icons.history_edu,
    'Geography': Icons.public,
    'Computer Science': Icons.computer,
    'Economics': Icons.trending_up,
    'Psychology': Icons.psychology,
    'Philosophy': Icons.school,
    'Statistics': Icons.bar_chart,
  };

  // Color mapping for subjects
  final Map<String, Color> subjectColors = {
    'Mathematics': Colors.blue,
    'Physics': Colors.purple,
    'Chemistry': Colors.green,
    'Biology': Colors.teal,
    'English': Colors.orange,
    'History': Colors.brown,
    'Geography': Colors.indigo,
    'Computer Science': Colors.cyan,
    'Economics': Colors.red,
    'Psychology': Colors.pink,
    'Philosophy': Colors.deepOrange,
    'Statistics': Colors.amber,
  };

  @override
  void initState() {
    super.initState();
    _initializeSelectedGrade();
    _initializeSelectedBooks();
    // Load available books for this grade
    context.read<SettingsBloc>().add(
      SettingsLoadAvailableBooks(widget.selectedGrade),
    );
  }

  void _initializeSelectedGrade() {
    final settingsState = context.read<SettingsBloc>().state;
    final localGrade = _getGradeFromState(settingsState);
    selectedGrade = localGrade ?? widget.selectedGrade;
  }

  void _initializeSelectedBooks() {
    // Get the latest student data from StudentBloc
    final studentState = context.read<StudentBloc>().state;

    if (studentState is StudentDataLoaded) {
      final student = studentState.student;

      print("Loaded ${student.selectedBooks} books from selectedBooks field");
      _setSelectedBooksFromStudent(student);
    } else {
      // Fallback to widget.student if StudentBloc hasn't loaded yet
      _setSelectedBooksFromStudent(widget.student);
    }

    isInitialized = true;
    print(
      "Initialized with ${selectedBookIds.length} selected books: $selectedBookIds",
    );
  }

  void _setSelectedBooksFromStudent(StudentModel student) {
    // Priority 1: Use selectedBooks if available (new method)
    if (student.selectedBooks.isNotEmpty) {
      selectedBookIds = List<String>.from(
        student.selectedBooks.map((book) => book.id),
      );
      print("Loaded ${selectedBookIds.length} books from selectedBooks field");
    }
    // Priority 2: Fallback to matching books by subject names (legacy method)
    else if (student.subjects.isNotEmpty) {
      print(
        "No selectedBooks found, will match by subjects: ${student.subjects}",
      );
      // We'll match books when they load from API
      // Store subjects temporarily for matching
      _pendingSubjectsToMatch = List<String>.from(student.subjects);
    } else {
      print("No books or subjects found in student data");
    }
  }

  List<String>? _pendingSubjectsToMatch;

  void _matchBooksBySubjects(List<BookModel> books) {
    if (_pendingSubjectsToMatch != null &&
        _pendingSubjectsToMatch!.isNotEmpty) {
      List<String> matchedBookIds = [];
      for (final subject in _pendingSubjectsToMatch!) {
        final matchedBooks = books.where((book) => book.subject == subject);
        matchedBookIds.addAll(matchedBooks.map((book) => book.id));
      }

      if (matchedBookIds.isNotEmpty) {
        setState(() {
          selectedBookIds = matchedBookIds;
        });
        print("Matched ${matchedBookIds.length} books by subjects");
      }
      _pendingSubjectsToMatch = null;
    }
  }

  int? _getGradeFromState(SettingsState state) {
    if (state is SettingsGradeLoadedLocally) {
      return state.grade;
    } else if (state is SettingsGradeSavedLocal) {
      return state.grade;
    }
    return null;
  }

  IconData _getIconForSubject(String? subject) {
    return subjectIcons[subject] ?? Icons.book;
  }

  Color _getColorForSubject(String? subject) {
    return subjectColors[subject] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Select Books', style: context.textStyle.titleMedium),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (state is SettingsLoading) {
                setState(() => isLoading = true);
              } else if (state is SettingsAvailableBooksLoaded) {
                setState(() => isLoading = false);
                // Match books by subjects if we have pending subjects
                if (_pendingSubjectsToMatch != null) {
                  _matchBooksBySubjects(state.booksResponse.books);
                }
              } else if (state is SettingsUpdateSuccess) {
                setState(() => isLoading = false);
                // Refresh student data
                context.read<StudentBloc>().add(StudentFetchData());

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Books updated successfully!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              } else if (state is SettingsUpdateFailure) {
                setState(() => isLoading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.error}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                setState(() => isLoading = false);
              }
            },
          ),
          BlocListener<StudentBloc, StudentState>(
            listener: (context, state) {
              // Update selected books if student data is refreshed
              if (state is StudentDataLoaded && !isLoading) {
                final newStudent = state.student;
                if (newStudent.selectedBooks.isNotEmpty) {
                  final newSelectedBooks = List<String>.from(
                    newStudent.selectedBooks.map((book) => book.id),
                  );
                  if (!_listsEqual(selectedBookIds, newSelectedBooks)) {
                    setState(() {
                      selectedBookIds = newSelectedBooks;
                    });
                    print("Updated selected books from StudentBloc");
                  }
                }
              }
            },
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading && !isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SettingsAvailableBooksLoaded) {
              return _buildBooksContent(state.booksResponse.books);
            }

            if (state is SettingsUpdateFailure) {
              return _buildErrorWidget(state.error);
            }

            // Show loading while initial data loads
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!a.contains(b[i])) return false;
    }
    return true;
  }

  Widget _buildBooksContent(List<BookModel> books) {
    if (books.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildSectionHeader('Academic Preferences'),
          const SizedBox(height: 16),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BBColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: BBColors.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grade ${selectedGrade ?? widget.selectedGrade}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedBookIds.length} book${selectedBookIds.length != 1 ? 's' : ''} selected',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Books Section
          _buildSectionHeader('Available Books (${books.length})'),
          const SizedBox(height: 16),

          // Books Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final isSelected = selectedBookIds.contains(book.id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedBookIds.remove(book.id);
                    } else {
                      selectedBookIds.add(book.id);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? BBColors.primaryColor
                              : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: BBColors.primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Book Cover or Icon
                            if (book.coverImage != null &&
                                book.coverImage!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book.coverImage!,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildBookIcon(book);
                                  },
                                ),
                              )
                            else
                              _buildBookIcon(book),

                            const SizedBox(height: 12),

                            // Book Title
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                book.bookTitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? Colors.black87
                                          : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Subject Badge
                            if (book.subject != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getColorForSubject(
                                      book.subject,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    book.subject!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getColorForSubject(book.subject),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: BBColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // Helper Text
          if (selectedBookIds.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please select at least one book to continue',
                      style: TextStyle(color: Colors.orange[900], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 40),

          // Save Button
          _buildSaveButton(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBookIcon(BookModel book) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getColorForSubject(book.subject).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getIconForSubject(book.subject),
        size: 48,
        color: _getColorForSubject(book.subject),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient:
            selectedBookIds.isNotEmpty && !isLoading
                ? const LinearGradient(
                  colors: [BBColors.primaryColor, BBColors.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: selectedBookIds.isEmpty || isLoading ? Colors.grey[300] : null,
      ),
      child: ElevatedButton(
        onPressed:
            selectedBookIds.isNotEmpty && !isLoading
                ? () {
                  context.read<SettingsBloc>().add(
                    SettingsUpdateGradeAndBooks(
                      grade: selectedGrade!,
                      bookIds: selectedBookIds,
                    ),
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Save Selection',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        selectedBookIds.isNotEmpty
                            ? BBColors.white
                            : Colors.grey[600],
                  ),
                ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.blue[600],
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No books available for Grade ${widget.selectedGrade}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Books will appear here once they are added',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading books',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<SettingsBloc>().add(
                  SettingsLoadAvailableBooks(widget.selectedGrade),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
