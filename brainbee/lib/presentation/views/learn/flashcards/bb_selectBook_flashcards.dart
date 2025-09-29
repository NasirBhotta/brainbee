import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/learn/battle/bb_book_selection.dart';
import 'package:brainbee/presentation/views/learn/flashcards/bb_selectChap_flashcards.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';

class BBFlashcards extends StatelessWidget {
  int grade = 0;
  // All available subjects
  static final List<Subject> _allSubjects = [
    Subject(
      name: 'English',
      flashcardCount: 105,
      imgPath: 'assets/text-book.png',
      color: Colors.red,
    ),
    Subject(
      name: 'Biology',
      flashcardCount: 34,
      imgPath: 'assets/dna.png',
      color: Colors.green,
    ),
    Subject(
      name: 'Mathematics',
      flashcardCount: 35,
      imgPath: 'assets/compass.png',
      color: Colors.blue,
    ),
    Subject(
      name: 'Chemistry',
      flashcardCount: 29,
      imgPath: 'assets/chemistry.png',
      color: Colors.pink,
    ),
    Subject(
      name: 'Physics',
      flashcardCount: 25,
      imgPath: 'assets/molecule.png',
      color: Colors.amber,
    ),
  ];

  BBFlashcards({super.key});

  // Helper method to get registered subjects only
  List<Subject> _getRegisteredSubjects(List<String> registeredSubjects) {
    return _allSubjects.where((subject) {
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentDataError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is StudentDataLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudentDataLoaded) {
            grade = state.student.grade;
            final registeredSubjects = _getRegisteredSubjects(
              state.student.subjects,
            );

            if (registeredSubjects.isEmpty) {
              return _EmptySubjectsWidget();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: registeredSubjects.length,
              itemBuilder: (context, index) {
                final subject = registeredSubjects[index];
                return _FlashcardSubjectCard(
                  subject: subject,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BBChapterSelectionScreen(
                              subject: subject.name,
                              grade: grade,
                            ),
                      ),
                    );
                  },
                );
              },
            );
          }

          // Default fallback for other states
          return _EmptySubjectsWidget();
        },
      ),
    );
  }
}

// Extracted widget for flashcard subject card with improved design
class _FlashcardSubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const _FlashcardSubjectCard({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: BBColors.white,
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
                      color: subject.color,
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
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.style,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            BBText(
                              data: '${subject.flashcardCount} Flashcards',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Progress indicator and arrow
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: subject.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: BBText(
                          data: 'Study',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: subject.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
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

// Empty state widget when no subjects are registered
class _EmptySubjectsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.blue[50],
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 80,
              color: Colors.blue[400],
            ),
            const SizedBox(height: 20),
            BBText(
              data: "No Subjects Available",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BBText(
              data:
                  "Please register your subjects to access flashcards for studying",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.blue[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const BBText(
                data: "Go Back",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
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
}
