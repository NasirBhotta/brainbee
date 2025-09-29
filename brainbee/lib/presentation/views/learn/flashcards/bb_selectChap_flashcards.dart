// bb_chapter_selection_screen.dart
// Chapter selection screen with expandable sections

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
    context.read<BookContentBloc>().add(
      LoadBookChapters(subject: widget.subject, grade: widget.grade),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
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

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          centerTitle: true,
          title: Text(
            bookData.bookTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          floating: false,
          backgroundColor: BBColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                context.read<BookContentBloc>().add(
                  LoadBookChapters(
                    subject: widget.subject,
                    grade: widget.grade,
                  ),
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(color: BBColors.white),
            expandedTitleScale: 1,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: BBColors.primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BBText(
                          data:
                              '${bookData.chapters.length} Chapters Available',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BBText(
                          data: 'Tap on a chapter to view sections',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: bookData.chapters.length,
          itemBuilder: (context, index) {
            final chapter = bookData.chapters[index];
            return _ExpandableChapterCard(
              chapter: chapter,
              onSectionTap: (section) {
                _handleSectionTap(section);
              },
            );
          },
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

  void _handleSectionTap(ChapterSection section) {
    // Handle section tap - navigate to flashcards or content view
    // You can pass the section data to the next screen
    print('Section tapped: ${section.sectionTitle}');
  }
}

// Expandable Chapter Card Widget
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
            // Chapter Header
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Chapter number badge
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: BBColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: BBText(
                            data: '${widget.chapter.chapterNumber}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: BBColors.primaryColor,
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
                              data: widget.chapter.chapterTitle,
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
                                  data:
                                      '${widget.chapter.sections.length} Sections',
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

                      // Expand/Collapse icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sections List (Expandable)
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
                child: Column(
                  children: [
                    const Divider(height: 1, thickness: 1),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.chapter.sections.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                      itemBuilder: (context, index) {
                        final section = widget.chapter.sections[index];
                        return _SectionTile(
                          section: section,
                          sectionNumber: index + 1,
                          onTap: () => widget.onSectionTap(section),
                        );
                      },
                    ),
                  ],
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

// Section Tile Widget
class _SectionTile extends StatelessWidget {
  final ChapterSection section;
  final int sectionNumber;
  final VoidCallback onTap;

  const _SectionTile({
    required this.section,
    required this.sectionNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Section number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: BBColors.secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: BBText(
                    data: '$sectionNumber',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BBColors.secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Section title
              Expanded(
                child: BBText(
                  data: section.sectionTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
