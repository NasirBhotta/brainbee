import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/widgets/popups/bb_model_button.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_battle_quiz_screen.dart'; // Import your quiz screen
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

    // Simulate connection delay and update UI
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
          // Navigation is the key side-effect handled here
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

        // --- START: CORRECTED STATE DERIVATION LOGIC ---

        // An opponent is found in any state AFTER searching.
        final bool opponentFound =
            state is BattleOpponentFound ||
            state is BattleReady ||
            state is BattleInProgress;

        final BattleRoom? currentRoom =
            state is BattleSearching
                ? state.room
                : state is BattleRoomCreated
                ? state.room
                : state is BattleOpponentFound
                ? state.room
                : state is BattleReady
                ? state.room
                : state is BattleInProgress
                ? state.room
                : null;

        // Get the current user's ID from the BLoC
        final String? selfUserId = context.read<BattleBloc>().currentUserId;

        BattlePlayer? currentPlayer;
        BattlePlayer? opponentPlayer;

        // This is the new, reliable logic
        if (currentRoom != null && selfUserId != null) {
          if (currentRoom.host.id == selfUserId) {
            // I am the host
            currentPlayer = currentRoom.host;
            opponentPlayer = currentRoom.opponent;
          } else if (currentRoom.opponent?.id == selfUserId) {
            // I am the opponent
            currentPlayer = currentRoom.opponent;
            opponentPlayer = currentRoom.host;
          }
        }

        // Extract ready status ONLY from BattleReady state
        bool currentPlayerIsReady = false;
        bool opponentPlayerIsReady = false;
        if (state is BattleReady && currentPlayer != null) {
          // Use the IDs to be 100% certain
          if (currentRoom?.host.id == currentPlayer.id) {
            currentPlayerIsReady = state.isHostReady;
            opponentPlayerIsReady = state.isOpponentReady;
          } else {
            currentPlayerIsReady = state.isOpponentReady;
            opponentPlayerIsReady = state.isHostReady;
          }
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
                    // Connection Status Indicator
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
                            _buildPlayerCard(
                              name:
                                  currentPlayer?.username ??
                                  widget.currentPlayerName,
                              initial:
                                  currentPlayer?.avatarInitial ??
                                  widget.currentPlayerInitial,
                              color: widget.currentPlayerColor,
                              isCurrentPlayer: true,
                              isReady: currentPlayerIsReady,
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
                            _buildPlayerCard(
                              name: opponentPlayer?.username ?? 'Searching...',
                              initial: opponentPlayer?.avatarInitial ?? '?',
                              color:
                                  opponentFound
                                      ? BBColors.primaryColor
                                      : Colors.grey,
                              isCurrentPlayer: false,
                              isReady: opponentPlayerIsReady,
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
                    _buildActionButtons(opponentFound, currentPlayerIsReady),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToBattleScreen(BuildContext context, BattleInProgress state) {
    // Prevent multiple navigations if the listener fires rapidly
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

  Widget _buildActionButtons(bool opponentFound, bool currentPlayerIsReady) {
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
              onPressed:
                  opponentFound && _isConnected && !currentPlayerIsReady
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
                data: currentPlayerIsReady ? 'Waiting...' : 'Ready',
                style: TextStyle(
                  color:
                      opponentFound && _isConnected
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
          if (isReady)
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
    String? roomId;
    if (state is BattleSearching) roomId = state.room.roomId;
    if (state is BattleRoomCreated) roomId = state.room.roomId;
    if (state is BattleOpponentFound) roomId = state.room.roomId;
    if (state is BattleReady) roomId = state.room.roomId;

    if (roomId != null) {
      showDialog(
        context: context,
        builder: (dialogContext) => _buildCancelDialog(context, roomId!),
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
    String? roomId;
    if (state is BattleOpponentFound) roomId = state.room.roomId;
    if (state is BattleReady) roomId = state.room.roomId;

    if (roomId != null) {
      context.read<BattleBloc>().add(MarkReadyEvent(roomId: roomId));
    }
  }
}
