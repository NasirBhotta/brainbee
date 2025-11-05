import 'dart:async';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_battle_quiz_screen.dart';
import 'package:brainbee/presentation/views/learn/battle/bloc/battle_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MatchType { random, invitation }

class BbSearchingPlayers extends StatefulWidget {
  final MatchType matchType;
  final String? invitationCode;
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
  Timer? _timer;
  bool isMusic = false;
  BattleRoom? currentRoom;
  bool isOpponentFound = false;
  String? roomId;

  @override
  void initState() {
    super.initState();
    _initializeFromBlocState();
  }

  void _initializeFromBlocState() {
    final state = context.read<BattleBloc>().state;
    if (state is BattleRoomCreated ||
        state is BattleSearching ||
        state is BattleOpponentFound) {
      final room =
          state is BattleRoomCreated
              ? state.room
              : state is BattleSearching
              ? state.room
              : (state as BattleOpponentFound).room;

      setState(() {
        currentRoom = room;
        roomId = room.roomId;
        isOpponentFound = room.opponent != null;
      });

      if (isOpponentFound) {
        _startCountdown();
      }
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (countdown > 0) {
            countdown--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  void _copyInvitationCode() async {
    if (currentRoom?.invitationCode != null) {
      await Clipboard.setData(ClipboardData(text: currentRoom!.invitationCode));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation code copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleReady() {
    if (roomId != null) {
      context.read<BattleBloc>().add(MarkReadyEvent(roomId: roomId!));
    }
  }

  void _handleCancel() {
    if (roomId != null) {
      context.read<BattleBloc>().add(CancelBattleSearchEvent(roomId: roomId!));
    }
    Navigator.pop(context);
  }

  String _getWaitingText() {
    if (widget.matchType == MatchType.invitation) {
      if (widget.invitationCode != null) {
        return 'Joining match...';
      } else if (!isOpponentFound) {
        return 'Waiting for player to join';
      } else {
        return 'Player found! Starting match';
      }
    }
    return isOpponentFound ? 'Opponent found!' : 'Searching for opponent...';
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                  : "Random Battle",
          style: context.textStyle.titleMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: _handleCancel,
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: BBColors.white,
      ),
      body: BlocListener<BattleBloc, BattleState>(
        listener: (context, state) {
          if (state is BattleOpponentFound) {
            setState(() {
              currentRoom = state.room;
              isOpponentFound = true;
            });
            _startCountdown();
          } else if (state is BattleReady) {
            // Both players ready, waiting for battle to start
            if (state.isHostReady && state.isOpponentReady) {
              // Auto-start battle or wait for server confirmation
              if (roomId != null) {
                context.read<BattleBloc>().add(
                  StartBattleEvent(roomId: roomId!),
                );
              }
            }
          } else if (state is BattleInProgress) {
            // Navigate to quiz screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BBBattleQuizScreen(
                      room: state.room,
                      quizData: state.quizData,
                    ),
              ),
            );
          } else if (state is BattleError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is BattleCancelled) {
            Navigator.pop(context);
          }
        },
        child: _buildBody(),
      ),
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
          if (widget.matchType == MatchType.invitation &&
              currentRoom?.invitationCode != null &&
              !isOpponentFound)
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
                child: Icon(Icons.menu_book, color: Colors.blue[800], size: 24),
              ),
              const SizedBox(height: 8),
              BBText(
                data: currentRoom?.subject ?? 'Subject',
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
                    data: currentRoom!.invitationCode,
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
        if (isOpponentFound) ...[
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
        ] else
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
      ],
    );
  }

  Widget _buildPlayersSection() {
    final opponent = currentRoom?.opponent;

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
          opponent?.avatarInitial ?? '?',
          opponent != null
              ? Color(int.parse(opponent.avatarColor.replaceFirst('#', '0xFF')))
              : Colors.grey,
          opponent?.username ?? 'Waiting...',
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final state = context.watch<BattleBloc>().state;
    final bool canStart =
        state is BattleReady &&
        state.isHostReady &&
        state.isOpponentReady &&
        countdown == 0;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _handleCancel,
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
                  isOpponentFound && countdown == 0 ? _handleReady : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey.withValues(alpha: 0.2);
                  }
                  return BBColors.primaryBlue;
                }),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
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
                data: _getReadyButtonText(state),
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

  String _getReadyButtonText(BattleState state) {
    if (!isOpponentFound) {
      return 'Waiting...';
    }
    if (countdown > 0) {
      return 'Ready (00:${countdown.toString().padLeft(2, '0')})';
    }
    if (state is BattleReady) {
      if (state.isHostReady && state.isOpponentReady) {
        return 'Starting...';
      }
      return state.isHostReady ? 'Waiting for opponent...' : 'Ready';
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
