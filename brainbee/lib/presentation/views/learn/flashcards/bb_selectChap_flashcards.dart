// bb_chapter_selection_screen.dart
// Example implementation showing how to use the BookContentBloc

import 'package:brainbee/presentation/views/learn/bloc/learn_bloc.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/content.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';

class BBChapterSelectionScreen extends StatefulWidget {
  final String subject;
  final int grade;

  const BBChapterSelectionScreen({
    super.key,
    required this.subject,
    required this.grade,
  });

  @override
  State<BBChapterSelectionScreen> createState() =>
      _BBChapterSelectionScreenState();
}

class _BBChapterSelectionScreenState extends State<BBChapterSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Load chapters when screen initializes
    context.read<BookContentBloc>().add(
      LoadBookChapters(subject: widget.subject, grade: widget.grade),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BBText(
          data: '${widget.subject} - Grade ${widget.grade}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<BookContentBloc, BookContentState>(
        listener: (context, state) {
          if (state is BookContentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookContentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookChaptersLoaded) {
            return _buildChaptersList(state.bookData);
          }

          if (state is BookContentError) {
            return _buildErrorWidget(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildChaptersList(BookContentData bookData) {
    if (bookData.chapters.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Book title header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BBText(
                data: bookData.bookTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              BBText(
                data: '${bookData.chapters.length} Chapters Available',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Chapters list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: bookData.chapters.length,
            itemBuilder: (context, index) {
              final chapter = bookData.chapters[index];
              return _ChapterCard(
                chapter: chapter,
                onTap: () => _navigateToChapterDetails(chapter),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            Icon(Icons.menu_book_outlined, size: 80, color: Colors.blue[400]),
            const SizedBox(height: 20),
            BBText(
              data: "No Chapters Available",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BBText(
              data: "Chapters for this subject will be available soon",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.blue[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            BBText(
              data: "Error Loading Chapters",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BBText(
              data: message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<BookContentBloc>().add(
                  LoadBookChapters(
                    subject: widget.subject,
                    grade: widget.grade,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              child: const BBText(
                data: "Retry",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChapterDetails(BookChapter chapter) {
    // Navigate to chapter details screen
    // You can pass the chapter object or just the chapter ID
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BBChapterDetailsScreen(chapter: chapter),
    //   ),
    // );
  }
}

// Chapter Card Widget
class _ChapterCard extends StatelessWidget {
  final BookChapter chapter;
  final VoidCallback onTap;

  const _ChapterCard({required this.chapter, required this.onTap});

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
                  // Chapter number badge
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: BBText(
                        data: '${chapter.chapterNumber}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Chapter details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BBText(
                          data: chapter.chapterTitle,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.list_alt,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            BBText(
                              data: '${chapter.sections.length} Sections',
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
