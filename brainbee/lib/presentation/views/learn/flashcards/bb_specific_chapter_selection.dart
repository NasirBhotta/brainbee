import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/learn/bloc/learn_bloc.dart';
import 'package:brainbee/presentation/views/learn/flashcards/new%20screens/bb_flashcard.dart';
import 'package:brainbee/presentation/views/learn/flashcards/new%20screens/bb_topic_flashcard.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/flashcard_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Helper model to hold the grouped data for the UI
class GroupedFlashcardChapter {
  final String chapterTitle;
  final Map<String, List<Flashcard>> topics;

  GroupedFlashcardChapter({required this.chapterTitle, required this.topics});
}

class BbSpecificBookFlashcardSelection extends StatefulWidget {
  final String subject;
  final StudentModel student;

  const BbSpecificBookFlashcardSelection({
    super.key,
    required this.subject,
    required this.student,
  });

  @override
  State<BbSpecificBookFlashcardSelection> createState() =>
      _BbSpecificBookFlashcardSelectionState();
}

class _BbSpecificBookFlashcardSelectionState
    extends State<BbSpecificBookFlashcardSelection> {
  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  void _loadFlashcards() {
    // Construct the book name required by the API
    final bookName = "${widget.subject} ${widget.student.grade}th Class";
    context.read<BookContentBloc>().add(
      LoadFlashcards(studentId: widget.student.id, bookName: bookName),
    );
  }

  // Navigate to the generation screen
  void _onGenerateFlashcardsTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BbGenerateFlashcardsScreen(
              subject: widget.subject,
              student: widget.student,
            ),
      ),
    ).then((_) {
      // After returning from generation, refresh the list
      _loadFlashcards();
    });
  }

  // Navigate to the list of flashcards for a specific topic
  void _onTopicTap(String topicTitle, List<Flashcard> flashcards) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BbTopicFlashcardsListScreen(
              topicTitle: topicTitle,
              flashcards: flashcards,
            ),
      ),
    );
  }

  // Helper method to group the flat list of flashcards
  List<GroupedFlashcardChapter> _groupFlashcards(List<Flashcard> flashcards) {
    final Map<String, Map<String, List<Flashcard>>> chapterMap = {};

    for (final card in flashcards) {
      // Assumes topic_key format like "1.Anatomy" or "10.Nervous System"
      final parts = card.topicKey.split('.');
      if (parts.length < 2) continue;

      final chapterNum = parts[0];
      final topicTitle = parts.sublist(1).join('.');
      final chapterTitle = "Chapter $chapterNum";

      chapterMap.putIfAbsent(chapterTitle, () => {});
      chapterMap[chapterTitle]!.putIfAbsent(topicTitle, () => []);
      chapterMap[chapterTitle]![topicTitle]!.add(card);
    }

    return chapterMap.entries
        .map(
          (entry) => GroupedFlashcardChapter(
            chapterTitle: entry.key,
            topics: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) {
        // Sort chapters numerically
        final numA =
            int.tryParse(a.chapterTitle.replaceAll('Chapter ', '')) ?? 0;
        final numB =
            int.tryParse(b.chapterTitle.replaceAll('Chapter ', '')) ?? 0;
        return numA.compareTo(numB);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: true,
            title: Text("${widget.subject} Flashcards"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadFlashcards,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _ChapterGenerationHeader(onTap: _onGenerateFlashcardsTap),
          ),
          BlocBuilder<BookContentBloc, BookContentState>(
            builder: (context, state) {
              if (state is FlashcardLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is FlashcardsLoaded) {
                final groupedData = _groupFlashcards(state.flashcards);
                if (groupedData.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No flashcards found. Try generating some!'),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: groupedData.length,
                  itemBuilder: (context, index) {
                    final chapter = groupedData[index];
                    return _ExpandableFlashcardChapter(
                      chapter: chapter,
                      onTopicTap: _onTopicTap,
                    );
                  },
                );
              }

              if (state is FlashcardError) {
                return SliverFillRemaining(
                  child: Center(child: Text(state.message)),
                );
              }

              return const SliverFillRemaining(
                child: Center(child: Text('Loading flashcards...')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Header widget that navigates to the generation screen
class _ChapterGenerationHeader extends StatelessWidget {
  final VoidCallback onTap;
  const _ChapterGenerationHeader({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              "Generate New Flashcards",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom expandable card to display chapters and their topics
class _ExpandableFlashcardChapter extends StatefulWidget {
  final GroupedFlashcardChapter chapter;
  final Function(String, List<Flashcard>) onTopicTap;

  const _ExpandableFlashcardChapter({
    required this.chapter,
    required this.onTopicTap,
  });

  @override
  State<_ExpandableFlashcardChapter> createState() =>
      _ExpandableFlashcardChapterState();
}

class _ExpandableFlashcardChapterState
    extends State<_ExpandableFlashcardChapter> {
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BBText(
                              data: widget.chapter.chapterTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('${widget.chapter.topics.length} topics'),
                          ],
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
                child: Column(
                  children:
                      widget.chapter.topics.entries.map((topicEntry) {
                        final topicTitle = topicEntry.key;
                        final flashcards = topicEntry.value;
                        return ListTile(
                          title: Text(topicTitle),
                          subtitle: Text('${flashcards.length} flashcards'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap:
                              () => widget.onTopicTap(topicTitle, flashcards),
                        );
                      }).toList(),
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
