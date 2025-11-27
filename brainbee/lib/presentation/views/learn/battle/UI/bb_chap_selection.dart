import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/subject_model.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/widgets/popups/bb_invite_popUp.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_searching_players.dart';
import 'package:brainbee/presentation/views/learn/battle/bloc/battle_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:brainbee/presentation/views/learn/bloc/learn_bloc.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/content.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BBChapterSelectionScreen extends StatefulWidget {
  final Subject subject;
  final int grade;
  const BBChapterSelectionScreen({
    super.key,
    required this.subject,
    required this.grade,
  });

  @override
  _BBChapterSelectionScreenState createState() =>
      _BBChapterSelectionScreenState();
}

class _BBChapterSelectionScreenState extends State<BBChapterSelectionScreen> {
  final Map<String, bool> _selectedChapters = {};

  bool _hasNavigated = false;
  bool _isLoading = false;
  String? _selectedWholeChapterKey;

  @override
  void initState() {
    super.initState();
    context.read<BookContentBloc>().add(
      LoadBookChapters(subject: widget.subject.name, grade: widget.grade),
    );
  }

  int get _selectedCount => _selectedChapters.values.where((v) => v).length;

  void _toggleSelection(String key, {bool isWholeChapter = false}) {
    setState(() {
      if (isWholeChapter) {
        final isCurrentlySelected = _selectedWholeChapterKey == key;

        _selectedChapters.updateAll((k, v) => false);
        _selectedWholeChapterKey = null;

        if (!isCurrentlySelected) {
          _selectedWholeChapterKey = key;
          _selectedChapters[key] = true;
        }
      } else {
        final isCurrentlySelected = _selectedChapters[key] ?? false;

        if (_selectedWholeChapterKey != null) {
          _selectedChapters[_selectedWholeChapterKey!] = false;
          _selectedWholeChapterKey = null;
        }

        _selectedChapters[key] = !isCurrentlySelected;
      }
    });
  }

  List<String> _getBackendChaptersList() {
    if (_selectedWholeChapterKey != null) {
      return [_selectedWholeChapterKey!];
    } else {
      return _selectedChapters.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
    }
  }

  void _startMatch(BuildContext context) {
    final chaptersList = _getBackendChaptersList();

    if (chaptersList.isEmpty) return;

    showQuizSettingsPopup(context, widget.subject, chapters: chaptersList);
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<BattleBloc, BattleState>(
        listener: (context, state) {
          print("=== BBChapterSelectionScreen BlocListener ===");
          print("State: ${state.runtimeType}");
          print("_hasNavigated: $_hasNavigated");

          if (state is BattleLoading) {
            print("State is BattleLoading");
            setState(() => _isLoading = true);
          }

          if ((state is BattleSearching ||
                  state is BattleRoomCreated ||
                  state is BattleOpponentFound) &&
              !_hasNavigated) {
            print("Navigating to search screen from chapter selection...");
            _hasNavigated = true;
            setState(() => _isLoading = false);

            final studentState = context.read<StudentBloc>().state;
            String playerName = 'Player';
            String playerInitial = 'P';
            Color playerColor = const Color(0xFF8CAA56);

            if (studentState is StudentDataLoaded) {
              playerName = studentState.student.firstName;
              playerInitial =
                  playerName.isNotEmpty
                      ? playerName.substring(0, 1).toUpperCase()
                      : 'P';
            }

            final BattleRoom room;
            final MatchType matchType;

            if (state is BattleSearching) {
              room = state.room;
              matchType = MatchType.random;
            } else if (state is BattleOpponentFound) {
              room = state.room;

              matchType =
                  room.mode == BattleMode.random
                      ? MatchType.random
                      : MatchType.invitation;
            } else {
              room = (state as BattleRoomCreated).room;
              matchType = MatchType.invitation;
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BbSearchingPlayers(
                      matchType: matchType,
                      currentPlayerName: playerName,
                      currentPlayerInitial: playerInitial,
                      currentPlayerColor: playerColor,
                      invitationCode:
                          matchType == MatchType.invitation
                              ? room.invitationCode
                              : null,
                      roomId: room.roomId,
                    ),
              ),
            );
          } else if (state is BattleError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<BookContentBloc, BookContentState>(
                builder: (context, state) {
                  if (state is BookContentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is BookChaptersLoaded) {
                    return _buildChapterTopicList(state.bookData);
                  }

                  if (state is BookContentError) {
                    return _buildErrorWidget(state.message);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterTopicList(BookContentData bookData) {
    if (bookData.chapters.isEmpty) {
      return _buildEmptyState();
    }

    if (_selectedChapters.isEmpty) {
      for (final chapter in bookData.chapters) {
        _selectedChapters[chapter.chapterNumber.toString()] = false;

        for (final section in chapter.sections) {
          _selectedChapters['${chapter.chapterNumber}::${section.sectionTitle}'] =
              false;
        }
      }
    }

    return SingleChildScrollView(
      child: Column(
        children:
            bookData.chapters.map((chapter) {
              final chapterKey = chapter.chapterNumber.toString();
              return _BattleChapterCard(
                chapter: chapter,
                isChapterSelected: _selectedChapters[chapterKey] ?? false,
                onChapterTap:
                    () => _toggleSelection(chapterKey, isWholeChapter: true),
                onSectionTap: (section) {
                  final topicKey =
                      '${chapter.chapterNumber}::${section.sectionTitle}';
                  _toggleSelection(topicKey);
                },
                isTopicSelected: (section) {
                  final topicKey =
                      '${chapter.chapterNumber}::${section.sectionTitle}';
                  return _selectedChapters[topicKey] ?? false;
                },
                isLoading: _isLoading,
              );
            }).toList(),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
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
          BBText(
            data: 'Selected: $_selectedCount',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          ElevatedButton(
            onPressed:
                _selectedCount > 0 && !_isLoading
                    ? () => _startMatch(context)
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          BBColors.white,
                        ),
                      ),
                    )
                    : const BBText(
                      data: 'Start Battle',
                      style: TextStyle(
                        color: BBColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
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
                    subject: widget.subject.name,
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
}

class _BattleChapterCard extends StatelessWidget {
  final BookChapter chapter;
  final bool isChapterSelected;
  final VoidCallback onChapterTap;
  final Function(ChapterSection) onSectionTap;
  final bool Function(ChapterSection) isTopicSelected;
  final bool isLoading;

  const _BattleChapterCard({
    required this.chapter,
    required this.isChapterSelected,
    required this.onChapterTap,
    required this.onSectionTap,
    required this.isTopicSelected,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final hasTopicsSelected = chapter.sections.any(isTopicSelected);

    Color borderColor = Colors.transparent;
    if (isChapterSelected) {
      borderColor = BBColors.primaryColor;
    } else if (hasTopicsSelected) {
      borderColor = BBColors.secondaryColor.withOpacity(0.7);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: BBColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: EdgeInsets.zero,
            leading: InkWell(
              onTap: isLoading ? null : onChapterTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isChapterSelected
                          ? BBColors.primaryColor
                          : Colors.grey[200],
                  border: Border.all(color: BBColors.primaryColor, width: 1.5),
                ),
                child:
                    isChapterSelected
                        ? const Icon(
                          Icons.check,
                          size: 16,
                          color: BBColors.white,
                        )
                        : const SizedBox.shrink(),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: BBColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: BBText(
                      data: '${chapter.chapterNumber}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: BBColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                      BBText(
                        data:
                            'Tap circle for Whole Chapter | Tap arrow to select Topics',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: BBText(
                        data: 'Select Specific Topics:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: chapter.sections.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            indent: 52,
                            endIndent: 16,
                            color: Colors.grey[200],
                          ),
                      itemBuilder: (context, index) {
                        final section = chapter.sections[index];
                        return _BattleSectionTile(
                          section: section,
                          sectionNumber: index + 1,
                          isSelected: isTopicSelected(section),
                          onTap:
                              isLoading ? () {} : () => onSectionTap(section),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BattleSectionTile extends StatelessWidget {
  final ChapterSection section;
  final int sectionNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const _BattleSectionTile({
    required this.section,
    required this.sectionNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? BBColors.secondaryColor : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected
                            ? BBColors.secondaryColor
                            : Colors.grey[400]!,
                    width: 1.5,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(
                          Icons.check,
                          size: 12,
                          color: BBColors.white,
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BBText(
                  data: section.sectionTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color:
                        isSelected ? BBColors.secondaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
