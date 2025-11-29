// import 'package:brainbee/core/widgets/quiz%20generation/bb_chapter_card.dart';
// import 'package:brainbee/presentation/views/home/quizzes/bloc/quiz_bloc.dart';
// import 'package:brainbee/presentation/views/home/quizzes/models/book_model.dart';
// import 'package:flutter/material.dart';
// import 'package:brainbee/core/constants/bb_colors.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class BbChapterSectionsScreen extends StatefulWidget {
//   final Map<String, dynamic> bookData;
//   final List<Chapter> chaptersToDisplay;

//   const BbChapterSectionsScreen({
//     super.key,
//     required this.bookData,
//     required this.chaptersToDisplay,
//   });

//   @override
//   State<BbChapterSectionsScreen> createState() =>
//       _BbChapterSectionsScreenState();
// }

// class _BbChapterSectionsScreenState extends State<BbChapterSectionsScreen> {
//   late String _bookTitle;
//   late List<dynamic> _chapters;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _bookTitle = widget.bookData['data']['book_title'] ?? 'Unknown Book';
//     _chapters = widget.bookData['data']['chapters'] ?? [];
//   }

//   void _onSectionTap(Topic section) {
//     // ✅ Check if section is unlocked before allowing quiz generation
//     final bool isUnlocked =
//         section.isUnlocked; // Default true for backward compatibility

//     if (!isUnlocked) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'This section is locked. Complete previous sections first.',
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     print("the topic key for generating quiz is ${section.topic}");
//     // Generate quiz for unlocked section
//     context.read<QuizBloc>().add(
//       GenerateNewQuiz(topicKey: section.topic, bookName: _bookTitle),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener<QuizBloc, QuizState>(
//         listener: (context, state) {
//           if (state is QuizGenerating) {
//             setState(() {
//               isLoading = true;
//             });
//           } else if (state is QuizGenerated) {
//             setState(() {
//               isLoading = false;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.green,
//               ),
//             );
//             // ✅ Optionally navigate back after successful generation
//             Navigator.pop(context);
//           } else if (state is QuizError) {
//             setState(() {
//               isLoading = false;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         },
//         child: Stack(
//           children: [
//             CustomScrollView(
//               slivers: [
//                 SliverAppBar(
//                   pinned: true,
//                   centerTitle: true,
//                   title: Text(
//                     _bookTitle,
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                   floating: false,
//                   backgroundColor: BBColors.secondaryColor,
//                   elevation: 0,
//                   leading: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.black),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Container(color: BBColors.white),
//                     expandedTitleScale: 1,
//                   ),
//                 ),
//                 _chapters.isEmpty
//                     ? const SliverFillRemaining(
//                       child: Center(child: Text('No chapters available')),
//                     )
//                     : SliverPadding(
//                       padding: const EdgeInsets.only(top: 16),
//                       sliver: SliverList.builder(
//                         itemBuilder: (context, index) {
//                           final chapter = widget.chaptersToDisplay[index];
//                           return BbChapterCard.fromChapter(
//                             chapter: chapter,
//                             onTopicTap: _onSectionTap,
//                           );
//                         },
//                         itemCount: _chapters.length,
//                       ),
//                     ),
//               ],
//             ),

//             // ✅ Loading overlay
//             if (isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.5),
//                 child: Center(
//                   child: Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           CircularProgressIndicator(),
//                           SizedBox(height: 16),
//                           Text(
//                             'Generating quiz...',
//                             style: Theme.of(context).textTheme.titleMedium,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
