import 'package:brainbee/core/widgets/quiz%20generation/bb_chapter_card.dart';
import 'package:brainbee/presentation/views/home/quizzes/bloc/quiz_bloc.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbChapterSectionsScreen extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const BbChapterSectionsScreen({super.key, required this.bookData});

  @override
  State<BbChapterSectionsScreen> createState() =>
      _BbChapterSectionsScreenState();
}

class _BbChapterSectionsScreenState extends State<BbChapterSectionsScreen> {
  late String _bookTitle;
  late List<dynamic> _chapters;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _bookTitle = widget.bookData['data']['book_title'] ?? 'Unknown Book';
    _chapters = widget.bookData['data']['chapters'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<QuizBloc, QuizState>(
        listener: (context, state) {
          setState(() {
            if (state is QuizGenerating) {
              isLoading = true;
            } else {
              isLoading = false;
            }
          });
        },
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      centerTitle: true,
                      title: Text(
                        _bookTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      floating: false,
                      backgroundColor: BBColors.secondaryColor,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.black),
                          onPressed: () {
                            // Add refresh functionality if needed
                          },
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(color: BBColors.white),
                        expandedTitleScale: 1,
                      ),
                    ),
                    _chapters.isEmpty
                        ? const SliverFillRemaining(
                          child: Center(child: Text('No chapters available')),
                        )
                        : SliverList.builder(
                          itemBuilder: (context, index) {
                            final chapter = _chapters[index];
                            return BbChapterCard.fromJsonChapter(
                              chapter: chapter,
                              onSectionTap: (section) {
                                context.read<QuizBloc>().add(
                                  GenerateNewQuiz(
                                    topicKey: section['section_title'],
                                    bookName: _bookTitle,
                                  ),
                                );
                              },
                            );
                          },
                          itemCount: _chapters.length,
                        ),
                  ],
                ),
      ),
    );
  }
}
