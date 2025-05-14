import 'package:brainbee/core/models/bb_chapter.dart';
import 'package:brainbee/core/widgets/popups/bb_invite_popUp.dart';

import 'package:brainbee/presentation/views/battle/bb_book_selection.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';

class BBChapterSelectionScreen extends StatefulWidget {
  final Subject subject;

  const BBChapterSelectionScreen({super.key, required this.subject});

  @override
  _BBChapterSelectionScreenState createState() =>
      _BBChapterSelectionScreenState();
}

class _BBChapterSelectionScreenState extends State<BBChapterSelectionScreen> {
  final Map<String, bool> _selectedChapters = {};

  late List<Chapter> _chapters;

  @override
  void initState() {
    super.initState();

    _chapters = _getChaptersForSubject(widget.subject.name);

    for (var chapter in _chapters) {
      _selectedChapters[chapter.name] = false;
    }
  }

  List<Chapter> _getChaptersForSubject(String subjectName) {
    switch (subjectName) {
      case 'English':
        return [
          Chapter(name: 'Parts of Speech'),
          Chapter(name: 'Reading Comprehension'),
          Chapter(name: 'Writing Skills'),
          Chapter(name: 'Grammar'),
          Chapter(name: 'Literature'),
        ];
      case 'Mathematics':
        return [
          Chapter(name: 'Algebra'),
          Chapter(name: 'Geometry'),
          Chapter(name: 'Trigonometry'),
          Chapter(name: 'Calculus'),
          Chapter(name: 'Statistics'),
        ];
      case 'Biology':
        return [
          Chapter(name: 'Cell Biology'),
          Chapter(name: 'Genetics'),
          Chapter(name: 'Human Anatomy'),
          Chapter(name: 'Ecology'),
          Chapter(name: 'Evolution'),
        ];
      case 'Chemistry':
        return [
          Chapter(name: 'Atomic Structure'),
          Chapter(name: 'Chemical Bonding'),
          Chapter(name: 'Periodic Table'),
          Chapter(name: 'Organic Chemistry'),
          Chapter(name: 'Stoichiometry'),
        ];
      case 'Physics':
        return [
          Chapter(name: 'Mechanics'),
          Chapter(name: 'Thermodynamics'),
          Chapter(name: 'Electromagnetism'),
          Chapter(name: 'Optics'),
          Chapter(name: 'Modern Physics'),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BBText(
          data: 'Select Chapters - ${widget.subject.name}',
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: BBColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            _selectedChapters[chapter.name]!
                                ? BBColors.secondaryColor
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CheckboxListTile(
                      title: BBText(
                        data: chapter.name,
                        style: context.textStyle.titleMedium?.copyWith(
                          fontSize: 16,
                          color:
                              _selectedChapters[chapter.name]!
                                  ? BBColors.secondaryColor
                                  : Colors.black,
                        ),
                      ),

                      value: _selectedChapters[chapter.name] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedChapters[chapter.name] = value ?? false;
                        });
                      },
                      checkColor: BBColors.white,
                      activeColor: BBColors.secondaryColor,
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: BBColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BBText(
                      data:
                          'Selected Chapters: ${_selectedChapters.values.where((v) => v).length}',
                      style: context.textStyle.bodyMedium,
                    ),
                  ],
                ),

                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [BBColors.primaryColor, BBColors.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        _selectedChapters.values.contains(true)
                            ? () {
                              showInvitationPopUp(
                                context: context,
                                title: "Invite Friends",
                                desc: "Are you ready?",
                                button1Label: "Share invitation code",
                                button2Label: "Random Match",
                                subject: widget.subject,
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: BBText(
                      data: 'Start Match',
                      style: context.textStyle.titleSmall?.copyWith(
                        color: BBColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
