import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/subject_model.dart';
import 'package:brainbee/presentation/views/learn/Books/bb_view_chapter.dart';
import 'package:brainbee/presentation/views/learn/bloc/learn_bloc.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/content.model.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbSelectChapter extends StatefulWidget {
  final Subject subject;
  final int grade;
  const BbSelectChapter({
    super.key,
    required this.subject,
    required this.grade,
  });

  @override
  BbSelectChapterState createState() => BbSelectChapterState();
}

class BbSelectChapterState extends State<BbSelectChapter> {
  @override
  void initState() {
    super.initState();
    context.read<BookContentBloc>().add(
      LoadBookChapters(subject: widget.subject.name, grade: widget.grade),
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
          data: '${widget.subject.name} - Chapters',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<BookContentBloc, BookContentState>(
        builder: (context, state) {
          if (state is BookContentLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      BBColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BBText(
                    data: 'Loading chapters...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (state is BookContentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const BBText(
                    data: 'Something went wrong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BBText(
                    data: state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<BookContentBloc>().add(
                        LoadBookChapters(
                          subject: widget.subject.name,
                          grade: widget.grade,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BBColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is BookChaptersLoaded) {
            final chapters = state.bookData.chapters;

            if (chapters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const BBText(
                      data: 'No Chapters Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return _ChapterCard(
                  chapter: chapter,
                  chapterNumber: index + 1,
                  subjectColor: widget.subject.color,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BbViewChapter(chapter: chapter),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final BookChapter chapter;
  final int chapterNumber;
  final Color subjectColor;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.chapterNumber,
    required this.subjectColor,
    required this.onTap,
  });

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
                  // Chapter number with colored background
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: subjectColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: BBText(
                        data: '$chapterNumber',
                        style: TextStyle(
                          color: subjectColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Chapter name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BBText(
                          data: 'Chapter $chapterNumber',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 4),
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
