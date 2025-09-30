import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/learn/bloc/learn_bloc.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/content.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbGenerateFlashcardsScreen extends StatefulWidget {
  final String subject;
  final StudentModel student;

  const BbGenerateFlashcardsScreen({
    super.key,
    required this.subject,
    required this.student,
  });

  @override
  State<BbGenerateFlashcardsScreen> createState() =>
      _BbGenerateFlashcardsScreenState();
}

class _BbGenerateFlashcardsScreenState
    extends State<BbGenerateFlashcardsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookContentBloc>().add(
      LoadBookChapters(subject: widget.subject, grade: widget.student.grade),
    );
  }

  void _onGenerateTap(ChapterSection section, String bookTitle) {
    context.read<BookContentBloc>().add(
      GenerateFlashcards(
        studentId: widget.student.id,
        subject: bookTitle,
        topicQuery: section.sectionTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<BookContentBloc, BookContentState>(
        listener: (context, state) {
          if (state is FlashcardGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Pop back to the previous screen on success
            Navigator.of(context).pop();
          } else if (state is FlashcardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              centerTitle: true,
              title: const Text("Generate Flashcards"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            BlocBuilder<BookContentBloc, BookContentState>(
              builder: (context, state) {
                if (state is BookContentLoading ||
                    state is FlashcardGenerating) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is BookChaptersLoaded) {
                  if (state.bookData.chapters.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text('No chapters available to generate from.'),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: state.bookData.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = state.bookData.chapters[index];
                      return _ExpandableChapterCard(
                        chapter: chapter,
                        onSectionTap:
                            (section) => _onGenerateTap(
                              section,
                              state.bookData.bookTitle,
                            ),
                      );
                    },
                  );
                }

                if (state is BookContentError) {
                  return SliverFillRemaining(
                    child: Center(child: Text(state.message)),
                  );
                }

                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Select a chapter and section to begin.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableChapterCard extends StatefulWidget {
  final BookChapter chapter;
  final Function(ChapterSection) onSectionTap;
  const _ExpandableChapterCard({
    required this.chapter,
    required this.onSectionTap,
  });
  @override
  State<_ExpandableChapterCard> createState() => _ExpandableChapterCardState();
}

class _ExpandableChapterCardState extends State<_ExpandableChapterCard> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: BBText(
                          data:
                              'Chapter ${widget.chapter.chapterNumber}: ${widget.chapter.chapterTitle}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.chapter.sections.length,
                  separatorBuilder:
                      (context, index) =>
                          Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final section = widget.chapter.sections[index];
                    return ListTile(
                      title: BBText(data: section.sectionTitle),
                      trailing: const Icon(
                        Icons.generating_tokens_outlined,
                        color: BBColors.primaryColor,
                      ),
                      onTap: () => widget.onSectionTap(section),
                    );
                  },
                ),
              ),
              crossFadeState:
                  _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
