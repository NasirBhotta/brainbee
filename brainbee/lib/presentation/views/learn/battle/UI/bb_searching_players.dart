import 'dart:async';
import 'dart:math';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/learn/battle/bb_battle_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MatchType { random, invitation }

class BbSearchingPlayers extends StatefulWidget {
  final MatchType matchType;
  final String? invitationCode; // For joining with code
  final String currentPlayerName;
  final String currentPlayerInitial;
  final Color currentPlayerColor;

  const BbSearchingPlayers({
    super.key,
    required this.matchType,
    required this.currentPlayerName,
    required this.currentPlayerInitial,
    required this.currentPlayerColor,
    this.invitationCode,
  });

  @override
  State<BbSearchingPlayers> createState() => _BbSearchingPlayersState();
}

class _BbSearchingPlayersState extends State<BbSearchingPlayers> {
  int countdown = 15;
  late Timer _timer;
  bool isMusic = false;
  String? generatedInvitationCode;
  bool isPlayerMatched = false;
  String? matchedPlayerName;
  String? matchedPlayerInitial;
  Color? matchedPlayerColor;
  bool timerInitialized = false;
  bool isRandomPlayerMatched = false;

  @override
  void initState() {
    super.initState();
    _initializeMatch();
  }

  void _initializeMatch() {
    if (widget.matchType == MatchType.invitation &&
        widget.invitationCode == null) {
      // Generate invitation code for sharing
      _generateInvitationCode();
      _startWaitingForPlayer();
    } else {
      // Start countdown for random match or joining with code
      _startCountdown(MatchType.random);
    }
  }

  void _generateInvitationCode() {
    // Generate a 6-digit random code
    final random = Random();
    generatedInvitationCode = (100000 + random.nextInt(900000)).toString();
  }

  void _startWaitingForPlayer() {
    // Simulate waiting for another player to join
    // In real implementation, this would listen to my backend/websocket
    Timer(Duration(seconds: 5 + Random().nextInt(10)), () {
      if (mounted) {
        setState(() {
          isPlayerMatched = true;
          matchedPlayerName = 'student${Random().nextInt(999)}';
          matchedPlayerInitial =
              matchedPlayerName!.substring(0, 1).toUpperCase();
          matchedPlayerColor = _getRandomColor();
        });
        _startCountdown(MatchType.invitation);
      }
    });
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFE94A76),
      const Color(0xFF8CAA56),
      const Color(0xFF4A90E2),
      const Color(0xFFFF8C00),
      const Color(0xFF9B59B6),
    ];
    return colors[Random().nextInt(colors.length)];
  }

  void _startCountdown(MatchType matchType) {
    if (matchType == MatchType.random) {
      isRandomPlayerMatched = true;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          _timer.cancel();
        }
      });
    });
    timerInitialized = true;
  }

  void _copyInvitationCode() async {
    if (generatedInvitationCode != null) {
      await Clipboard.setData(ClipboardData(text: generatedInvitationCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation code copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getWaitingText() {
    if (widget.matchType == MatchType.invitation) {
      if (widget.invitationCode != null) {
        return 'Joining match...';
      } else if (!isPlayerMatched) {
        return 'Waiting for player to join';
      } else {
        return 'Player found! Starting match';
      }
    }
    return 'Waiting for a match';
  }

  @override
  void dispose() {
    if (timerInitialized) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BBText(
          data:
              widget.matchType == MatchType.invitation
                  ? "Private Battle"
                  : "Start Battle",
          style: context.textStyle.titleMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: BBColors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: BBColors.borderGray)),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: context.screenHeight * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [BBColors.primaryColor, BBColors.secondaryColor],
          begin: Alignment(0, 1),
          end: Alignment(0, -1),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: context.screenHeight * 0.03),

          // Show invitation code if generating one
          if (widget.matchType == MatchType.invitation &&
              generatedInvitationCode != null &&
              !isPlayerMatched)
            _buildInvitationCodeSection(),

          SizedBox(height: context.screenHeight * 0.03),

          _buildWaitingSection(),
          SizedBox(height: context.screenHeight * 0.03),
          _buildPlayersSection(),
          const SizedBox(height: 30),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.only(
            right: 20,
            left: 10,
            top: 10,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/compass.png',
                  width: 24,
                  height: 24,
                  color: Colors.blue,
                  errorBuilder:
                      (context, error, stack) => Icon(
                        Icons.calculate,
                        color: Colors.blue[800],
                        size: 24,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              BBText(
                data: 'Mathematics',
                style: context.textStyle.titleSmall?.copyWith(
                  color: BBColors.bodyText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon:
                isMusic
                    ? const Icon(Icons.volume_up)
                    : const Icon(Icons.volume_off_outlined),
            color: Colors.grey,
            onPressed: () {
              setState(() {
                isMusic = !isMusic;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvitationCodeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BBText(
            data: 'Invitation Code',
            style: context.textStyle.titleMedium?.copyWith(
              color: BBColors.bodyText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          BBText(
            data: 'Share this code with your friend',
            style: context.textStyle.bodySmall?.copyWith(
              color: BBColors.bodyText.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BBColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BBColors.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: BBText(
                    data: generatedInvitationCode!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: BBColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _copyInvitationCode,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BBColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: Colors.white,
                      size: 18,
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

  Widget _buildWaitingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BBText(
          data: _getWaitingText(),
          style: context.textStyle.bodyLarge?.copyWith(
            color: BBColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.matchType == MatchType.random ||
            (widget.matchType == MatchType.invitation && isPlayerMatched)) ...[
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '$countdown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayersSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPlayer(
          widget.currentPlayerInitial,
          widget.currentPlayerColor,
          widget.currentPlayerName,
        ),
        Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: BBText(
              data: 'VS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _buildPlayer(
          _getOpponentInitial(),
          _getOpponentColor(),
          _getOpponentName(),
        ),
      ],
    );
  }

  String _getOpponentInitial() {
    if (widget.matchType == MatchType.invitation && isPlayerMatched) {
      return matchedPlayerInitial ?? '?';
    } else if (widget.matchType == MatchType.random) {
      return 'C';
    }
    return '?';
  }

  Color _getOpponentColor() {
    if (widget.matchType == MatchType.invitation && isPlayerMatched) {
      return matchedPlayerColor ?? const Color(0xFFE94A76);
    }
    return const Color(0xFFE94A76);
  }

  String _getOpponentName() {
    if (widget.matchType == MatchType.invitation && isPlayerMatched) {
      return matchedPlayerName ?? 'waiting';
    } else if (widget.matchType == MatchType.random) {
      return 'waiting';
    }
    return 'waiting';
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF6A6A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const BBText(
                data: 'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  _canStartMatch()
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BBBattleQuizScreen(),
                          ),
                        );
                      }
                      : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey.withValues(alpha: 0.2);
                  }
                  return BBColors.primaryBlue;
                }),
                foregroundColor: WidgetStateProperty.all<Color>(
                  Colors.white.withValues(alpha: 0.7),
                ),
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(vertical: 16),
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                elevation: WidgetStateProperty.all(0),
              ),
              child: BBText(
                data: _getReadyButtonText(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canStartMatch() {
    if (widget.matchType == MatchType.random) {
      return isRandomPlayerMatched && countdown <= 0;
    } else if (widget.matchType == MatchType.invitation) {
      return isPlayerMatched && countdown <= 0;
    }
    return false;
  }

  String _getReadyButtonText() {
    if (widget.matchType == MatchType.invitation && !isPlayerMatched) {
      return 'Waiting for player...';
    }

    if (countdown > 0) {
      return 'Ready (00:0${countdown > 0 ? countdown : 0})';
    }
    return 'Ready';
  }

  Widget _buildPlayer(String firstLetter, Color color, String fullName) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: BBText(
              data: firstLetter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        BBText(
          data: '@$fullName',
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }
}
