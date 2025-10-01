import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/subject_model.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/learn/Books/bb_select_chapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbSelectBook extends StatefulWidget {
  const BbSelectBook({super.key});

  @override
  State<BbSelectBook> createState() => _BbSelectBookState();
}

class _BbSelectBookState extends State<BbSelectBook> {
  final List<Subject> subjects = [
    Subject(
      name: 'English',

      imgPath: 'assets/text-book.png',
      color: Colors.red,
    ),
    Subject(name: 'Biology', imgPath: 'assets/dna.png', color: Colors.green),
    Subject(
      name: 'Mathematics',

      imgPath: 'assets/compass.png',
      color: Colors.blue,
    ),
    Subject(
      name: 'Chemistry',

      imgPath: 'assets/chemistry.png',
      color: Colors.pink,
    ),
    Subject(
      name: 'Physics',

      imgPath: 'assets/molecule.png',
      color: Colors.amber,
    ),
  ];

  List<Subject> _getRegisteredSubjects(List<String> registeredSubjects) {
    return subjects.where((subject) {
      return registeredSubjects.contains(subject.name);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BBText(
          data: 'Select Subject',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          // Loading State
          if (state is StudentDataLoading) {
            return _buildLoadingState();
          }

          // Error State
          if (state is StudentDataError) {
            return _buildErrorState(state.message);
          }

          // Loaded State
          if (state is StudentDataLoaded) {
            final registeredSubjects = _getRegisteredSubjects(
              state.student.subjects,
            );

            // Empty State
            if (registeredSubjects.isEmpty) {
              return _buildEmptyState();
            }

            return _buildSubjectsList(registeredSubjects, state.student.grade);
          }

          // Default fallback
          return _buildLoadingState();
        },
      ),
    );
  }

  // Loading state widget
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          BBText(
            data: 'Loading subjects...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Error state widget
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            BBText(
              data: 'Oops! Something went wrong',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            BBText(
              data: message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Retry loading
                context.read<StudentBloc>().add(StudentFetchData());
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            BBText(
              data: 'No Subjects Available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            BBText(
              data: 'You haven\'t registered for any subjects yet.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to subject registration or home
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Subjects list widget
  Widget _buildSubjectsList(List<Subject> registeredSubjects, int grade) {
    return Column(
      children: [
        // Subjects list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: registeredSubjects.length,
            itemBuilder: (context, index) {
              final subject = registeredSubjects[index];
              return _SubjectCard(
                subject: subject,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              BbSelectChapter(subject: subject, grade: grade),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Subject card widget with improved design
class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const _SubjectCard({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Subject icon with colored background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: subject.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      subject.imgPath,
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.book, size: 32, color: subject.color);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Subject details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BBText(
                          data: subject.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
