import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/widgets/popups/bb_model_button.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_battle_quiz_screen.dart';
import 'package:brainbee/presentation/views/learn/battle/bloc/battle_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MatchType { random, invitation }

class BbSearchingPlayers extends StatefulWidget {
  final MatchType matchType;
  final String currentPlayerName;
  final String currentPlayerInitial;
  final Color currentPlayerColor;
  final String? invitationCode;
  final String roomId;

  const BbSearchingPlayers({
    super.key,
    required this.matchType,
    required this.currentPlayerName,
    required this.currentPlayerInitial,
    required this.currentPlayerColor,
    required this.roomId,
    this.invitationCode,
  });

  @override
  State<BbSearchingPlayers> createState() => _BbSearchingPlayersState();
}

class _BbSearchingPlayersState extends State<BbSearchingPlayers>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  bool _isConnecting = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BattleBloc, BattleState>(
      listener: (context, state) {
        print("Listener received state: ${state.runtimeType}");
        if (state is BattleInProgress) {
          _navigateToBattleScreen(context, state);
        } else if (state is BattleCancelled) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is BattleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        print("Builder received state: ${state.runtimeType}");

        final String? selfUserId = context.read<BattleBloc>().currentUserId;
        print('🆔 Self User ID in UI: $selfUserId');

        // Get room from current state
        final BattleRoom? currentRoom = _getRoomFromState(state);

        // Determine if opponent is found
        final bool opponentFound =
            state is BattleOpponentFound ||
            state is BattleReady ||
            state is BattleInProgress;

        // FIX: Properly determine current player and opponent
        BattlePlayer? myPlayer;
        BattlePlayer? theirPlayer;

        if (currentRoom != null && selfUserId != null) {
          // Check if I am the host
          if (currentRoom.host.id == selfUserId) {
            myPlayer = currentRoom.host;
            theirPlayer = currentRoom.opponent;
            print('👤 I am HOST: ${myPlayer.username}');
            print('👥 Opponent: ${theirPlayer?.username ?? "waiting..."}');
          }
          // Check if I am the opponent
          else if (currentRoom.opponent?.id == selfUserId) {
            myPlayer = currentRoom.opponent;
            theirPlayer = currentRoom.host;
            print('👤 I am OPPONENT: ${myPlayer?.username}');
            print('👥 Host (my opponent): ${theirPlayer.username}');
          }
        }

        // FIX: Extract ready status correctly based on who I am
        bool myReadyStatus = false;
        bool theirReadyStatus = false;

        if (state is BattleReady && selfUserId != null && currentRoom != null) {
          // Determine ready status based on whether I'm host or opponent
          if (currentRoom.host.id == selfUserId) {
            // I am host
            myReadyStatus = state.isHostReady;
            theirReadyStatus = state.isOpponentReady;
          } else {
            // I am opponent
            myReadyStatus = state.isOpponentReady;
            theirReadyStatus = state.isHostReady;
          }
          print('✅ Ready states - Me: $myReadyStatus, Them: $theirReadyStatus');
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: BBText(
              data:
                  opponentFound
                      ? 'Opponent Found'
                      : widget.matchType == MatchType.random
                      ? 'Finding Opponent'
                      : 'Waiting for Opponent',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => _handleCancel(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
                child: Column(
                  children: [
                    if (_isConnecting)
                      _buildConnectionStatus(isConnecting: true),
                    if (_isConnected && !_isConnecting)
                      _buildConnectionStatus(isConnecting: false),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (!opponentFound) _buildSearchingAnimation(),
                            if (!opponentFound) const SizedBox(height: 40),
                            // MY PLAYER CARD (always "You")
                            _buildPlayerCard(
                              name:
                                  myPlayer?.username ??
                                  widget.currentPlayerName,
                              initial:
                                  myPlayer?.avatarInitial ??
                                  widget.currentPlayerInitial,
                              color: widget.currentPlayerColor,
                              isCurrentPlayer: true,
                              isReady: myReadyStatus,
                              opponentFound: opponentFound,
                            ),
                            const SizedBox(height: 24),
                            const BBText(
                              data: 'VS',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: BBColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // OPPONENT PLAYER CARD
                            _buildPlayerCard(
                              name: theirPlayer?.username ?? 'Searching...',
                              initial: theirPlayer?.avatarInitial ?? '?',
                              color:
                                  opponentFound
                                      ? BBColors.primaryColor
                                      : Colors.grey,
                              isCurrentPlayer: false,
                              isReady: theirReadyStatus,
                              opponentFound: opponentFound,
                            ),
                            const SizedBox(height: 40),
                            _buildStatusMessage(opponentFound),
                            if (widget.matchType == MatchType.invitation &&
                                widget.invitationCode != null)
                              _buildInvitationCodeSection(),
                          ],
                        ),
                      ),
                    ),
                    _buildActionButtons(opponentFound, myReadyStatus),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper to extract room from various states
  BattleRoom? _getRoomFromState(BattleState state) {
    if (state is BattleSearching) return state.room;
    if (state is BattleRoomCreated) return state.room;
    if (state is BattleOpponentFound) return state.room;
    if (state is BattleReady) return state.room;
    if (state is BattleInProgress) return state.room;
    return null;
  }

  void _navigateToBattleScreen(BuildContext context, BattleInProgress state) {
    if (ModalRoute.of(context)?.isCurrent ?? false) {
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
    }
  }

  Widget _buildConnectionStatus({required bool isConnecting}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isConnecting ? Colors.orange[100] : Colors.green[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isConnecting
              ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.orange[700]!,
                  ),
                ),
              )
              : Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            isConnecting ? 'Connecting to server...' : 'Connected',
            style: TextStyle(
              color: isConnecting ? Colors.orange[700] : Colors.green[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool opponentFound, bool myReadyStatus) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isConnected ? () => _handleCancel(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: BBText(
                data: 'Cancel',
                style: TextStyle(
                  color: _isConnected ? Colors.white : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              // FIX: Disable if already ready OR opponent not found
              onPressed:
                  opponentFound && _isConnected && !myReadyStatus
                      ? () => _handleReady(context)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: BBText(
                data: myReadyStatus ? 'Waiting...' : 'Ready',
                style: TextStyle(
                  color:
                      opponentFound && _isConnected && !myReadyStatus
                          ? Colors.white
                          : Colors.grey[600],
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

  Widget _buildSearchingAnimation() {
    return RotationTransition(
      turns: _rotationController,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: BBColors.primaryColor.withOpacity(0.3),
            width: 3,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BBColors.primaryColor.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.search,
                size: 40,
                color: BBColors.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required String initial,
    required Color color,
    required bool isCurrentPlayer,
    required bool isReady,
    required bool opponentFound,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlayer ? BBColors.primaryColor : Colors.grey[300]!,
          width: 2,
        ),
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
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: BBText(
              data: initial,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BBText(
                  data: name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                BBText(
                  data: isCurrentPlayer ? 'You' : 'Opponent',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Show ready indicator only for found opponents or if player is ready
          if (isReady && (isCurrentPlayer || opponentFound))
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 4),
                  BBText(
                    data: 'Ready',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          // Show searching animation for opponent when not found
          if (!isCurrentPlayer && !opponentFound)
            FadeTransition(
              opacity: _pulseController,
              child: const Icon(Icons.more_horiz, color: Colors.grey, size: 32),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(bool opponentFound) {
    String message;
    if (_isConnecting) {
      message = 'Establishing connection...';
    } else if (opponentFound) {
      message = 'Opponent found! Click Ready when you\'re prepared.';
    } else {
      message =
          widget.matchType == MatchType.random
              ? 'Searching for an opponent...'
              : 'Share the code below with your friend.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (opponentFound ? Colors.green : BBColors.primaryColor)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            opponentFound
                ? Icons.check_circle
                : widget.matchType == MatchType.random
                ? Icons.search
                : Icons.share,
            size: 20,
            color: opponentFound ? Colors.green : BBColors.primaryColor,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: BBText(
              data: message,
              style: TextStyle(
                fontSize: 14,
                color: opponentFound ? Colors.green : BBColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCodeSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          const BBText(
            data: 'Invitation Code',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BBColors.primaryColor, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BBText(
                  data: widget.invitationCode!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: BBColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.copy, color: BBColors.primaryColor),
                  onPressed: () => _copyInvitationCode(context),
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyInvitationCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.invitationCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation code copied!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCancel(BuildContext context) {
    final state = context.read<BattleBloc>().state;
    String? roomId = _getRoomFromState(state)?.roomId;

    if (roomId != null) {
      showDialog(
        context: context,
        builder: (dialogContext) => _buildCancelDialog(context, roomId),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildCancelDialog(BuildContext context, String roomId) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BBText(
                data: 'Cancel Match?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              BBText(
                data: 'Are you sure you want to cancel this match?',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildStudyModeButton(
                    context,
                    label: 'No',
                    onTap: () => Navigator.pop(context),
                  ),
                  buildStudyModeButton(
                    context,
                    label: 'Yes, Cancel',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<BattleBloc>().add(
                        CancelBattleSearchEvent(roomId: roomId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReady(BuildContext context) {
    final state = context.read<BattleBloc>().state;
    String? roomId = _getRoomFromState(state)?.roomId;

    if (roomId != null) {
      context.read<BattleBloc>().add(MarkReadyEvent(roomId: roomId));
    }
  }
}
