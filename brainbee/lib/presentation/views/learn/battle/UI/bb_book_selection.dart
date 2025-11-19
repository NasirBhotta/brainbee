import 'package:brainbee/core/models/subject_model.dart';
import 'package:brainbee/presentation/views/learn/battle/bloc/battle_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_searching_players.dart';
import 'package:brainbee/core/widgets/popups/bb_invite_popUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';

class BBBookSelectionForBattle extends StatefulWidget {
  const BBBookSelectionForBattle({super.key});

  @override
  State<BBBookSelectionForBattle> createState() =>
      _BBBookSelectionForBattleState();
}

class _BBBookSelectionForBattleState extends State<BBBookSelectionForBattle> {
  static final List<Subject> _allSubjects = [
    Subject(
      name: 'English',
      imgPath: 'assets/text-book.png',
      color: Colors.red,
    ),
    Subject(name: 'Biology', imgPath: 'assets/dna.png', color: Colors.green),
    Subject(
      name: 'Mathematics',
      imgPath: 'assets/compass.png',
      color: Colors.blue,
    ),
    Subject(
      name: 'Chemistry',
      imgPath: 'assets/chemistry.png',
      color: Colors.pink,
    ),
    Subject(
      name: 'Physics',
      imgPath: 'assets/molecule.png',
      color: Colors.amber,
    ),
  ];

  bool _hasNavigated = false;
  bool _isLoading = false;

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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<BattleBloc, BattleState>(
        listener: (context, state) {
          print("=== BBBookSelectionForBattle BlocListener ===");
          print("BattleBloc State: ${state.runtimeType}");
          print("_hasNavigated: $_hasNavigated");

          if (state is BattleLoading) {
            print("State is BattleLoading");
            setState(() => _isLoading = true);
          }

          // Only navigate once
          if ((state is BattleSearching ||
                  state is BattleRoomCreated ||
                  state is BattleOpponentFound) &&
              !_hasNavigated) {
            print("Navigating to search screen...");
            _hasNavigated = true;
            setState(() => _isLoading = false);

            _navigateToSearchScreen(context, state);
          } else if (state is BattleError) {
            print("Error: ${state.message}");
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
            if (state is StudentDataLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StudentDataLoaded) {
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
                  return _SubjectCard(
                    subject: subject,
                    onTap:
                        _isLoading
                            ? () {}
                            : () => _showStudyModeDialog(context, subject),
                  );
                },
              );
            }

            if (state is StudentDataError) {
              return Center(child: Text(state.message));
            }

            return _EmptySubjectsWidget();
          },
        ),
      ),
    );
  }

  void _showStudyModeDialog(BuildContext context, Subject subject) {
    showInvitationPopUp(
      context: context,
      title: "Battle Mode",
      desc: "How would you like to compete?",
      button1Label: "By Chapter",
      button2Label: "Whole Book",
      subject: subject,
      onButton1Pressed: () {
        _navigateToChapterSelection(context, subject);
      },
      onButton2Pressed: () {
        // Show quiz settings popup for whole book
        showQuizSettingsPopup(context, subject, chapters: null);
      },
    );
  }

  void _navigateToChapterSelection(BuildContext context, Subject subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BBChapterSelectionScreen(subject: subject),
      ),
    );
  }

  void _navigateToSearchScreen(BuildContext context, BattleState state) {
    final BattleRoom room;
    final MatchType matchType;

    if (state is BattleSearching) {
      room = state.room;
      matchType = MatchType.random;
    } else if (state is BattleRoomCreated) {
      room = state.room;
      matchType = MatchType.invitation;
    } else if (state is BattleOpponentFound) {
      // ✅ Add this case
      room = state.room;
      // Determine match type based on room mode
      matchType =
          room.mode == BattleMode.random
              ? MatchType.random
              : MatchType.invitation;
    } else {
      return;
    }

    // Get current user info from StudentBloc
    final studentState = context.read<StudentBloc>().state;
    String playerName = 'Player';
    String playerInitial = 'P';
    Color playerColor = const Color(0xFF8CAA56);

    if (studentState is StudentDataLoaded) {
      playerName = studentState.student.firstName ?? 'Player';
      playerInitial =
          playerName.isNotEmpty
              ? playerName.substring(0, 1).toUpperCase()
              : 'P';
    }

    Navigator.push(
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
    ).then((_) {
      // Reset navigation flag when returning from search screen
      _hasNavigated = false;
      setState(() => _isLoading = false);
    });
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const _SubjectCard({required this.subject, required this.onTap});

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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: subject.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(subject.imgPath, width: 32, height: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BBText(
                      data: subject.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
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
            Icon(Icons.school_outlined, size: 80, color: Colors.blue[400]),
            const SizedBox(height: 20),
            BBText(
              data: "No Subjects Registered",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BBText(
              data: "Please register your subjects to participate in battles",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.blue[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
              child: const BBText(
                data: "Go Back",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chapter Selection Screen
class BBChapterSelectionScreen extends StatefulWidget {
  final Subject subject;

  const BBChapterSelectionScreen({super.key, required this.subject});

  @override
  _BBChapterSelectionScreenState createState() =>
      _BBChapterSelectionScreenState();
}

class _BBChapterSelectionScreenState extends State<BBChapterSelectionScreen> {
  final Map<String, bool> _selectedChapters = {};
  late List<String> _chapters;
  bool _hasNavigated = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chapters = _getChaptersForSubject(widget.subject.name);
    for (var chapter in _chapters) {
      _selectedChapters[chapter] = false;
    }
  }

  List<String> _getChaptersForSubject(String subjectName) {
    switch (subjectName) {
      case 'English':
        return [
          'Parts of Speech',
          'Reading Comprehension',
          'Writing Skills',
          'Grammar',
          'Literature',
        ];
      case 'Mathematics':
        return [
          'Algebra',
          'Geometry',
          'Trigonometry',
          'Calculus',
          'Statistics',
        ];
      case 'Biology':
        return [
          'Cell Biology',
          'Genetics',
          'Human Anatomy',
          'Ecology',
          'Evolution',
        ];
      case 'Chemistry':
        return [
          'Atomic Structure',
          'Chemical Bonding',
          'Periodic Table',
          'Organic Chemistry',
          'Stoichiometry',
        ];
      case 'Physics':
        return [
          'Mechanics',
          'Thermodynamics',
          'Electromagnetism',
          'Optics',
          'Modern Physics',
        ];
      default:
        return [];
    }
  }

  void _startMatch(BuildContext context) {
    final selectedChapters =
        _selectedChapters.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedChapters.isEmpty) return;

    // Show quiz settings popup with selected chapters
    showInvitationPopUp(
      context: context,
      title: "Invite Friends",
      desc: "Are you ready?",
      button1Label: "Share invitation code",
      button2Label: "Random Match",
      subject: widget.subject,
      chapters: selectedChapters,
      onButton1Pressed: () {
        // Create invitation room with selected chapters
        print('Creating invitation room with chapters: $selectedChapters');
        context.read<BattleBloc>().add(
          CreateBattleRoomEvent(
            subject: widget.subject.name,
            mode: BattleMode.byChapter,
            chapters: selectedChapters,
          ),
        );
      },
      onButton2Pressed: () {
        // Find random opponent with selected chapters
        print('Finding random opponent with chapters: $selectedChapters');
        context.read<BattleBloc>().add(
          FindRandomOpponentEvent(
            subject: widget.subject.name,
            chapters: selectedChapters,
          ),
        );
      },
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

            // Get player info
            final studentState = context.read<StudentBloc>().state;
            String playerName = 'Player';
            String playerInitial = 'P';
            Color playerColor = const Color(0xFF8CAA56);

            if (studentState is StudentDataLoaded) {
              playerName = studentState.student.firstName ?? 'Player';
              playerInitial =
                  playerName.isNotEmpty
                      ? playerName.substring(0, 1).toUpperCase()
                      : 'P';
            }

            // Navigate to search screen
            final BattleRoom room;
            final MatchType matchType;

            if (state is BattleSearching) {
              room = state.room;
              matchType = MatchType.random;
            } else if (state is BattleOpponentFound) {
              // ✅ Add explicit handling
              room = state.room;
              // Determine match type from room mode
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
                              _selectedChapters[chapter]!
                                  ? BBColors.primaryColor
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CheckboxListTile(
                        title: BBText(
                          data: chapter,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                _selectedChapters[chapter]!
                                    ? BBColors.primaryColor
                                    : Colors.black,
                          ),
                        ),
                        value: _selectedChapters[chapter] ?? false,
                        onChanged:
                            _isLoading
                                ? null
                                : (bool? value) {
                                  setState(() {
                                    _selectedChapters[chapter] = value ?? false;
                                  });
                                },
                        checkColor: BBColors.white,
                        activeColor: BBColors.primaryColor,
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
                  Text(
                    'Selected: ${_selectedChapters.values.where((v) => v).length}',
                  ),
                  ElevatedButton(
                    onPressed:
                        _selectedChapters.values.contains(true) && !_isLoading
                            ? () => _startMatch(context)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BBColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
                              data: 'Start Match',
                              style: TextStyle(
                                color: BBColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
