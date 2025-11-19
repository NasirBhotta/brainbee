import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/bloc/battle_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/widgets/popups/bb_model_button.dart';

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
        print("Battle State Changed: ${state.runtimeType}");

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
        // ✅ Derive opponent found status from BLoC state
        final bool opponentFound =
            state is BattleOpponentFound || state is BattleReady;
        final BattleRoom? currentRoom =
            state is BattleOpponentFound
                ? state.room
                : state is BattleReady
                ? state.room
                : state is BattleSearching
                ? state.room
                : state is BattleRoomCreated
                ? state.room
                : null;

        print(
          '🔍 UI State - opponentFound: $opponentFound, currentRoom: ${currentRoom?.roomId}',
        );
        if (currentRoom?.opponent != null) {
          print('   Opponent: ${currentRoom!.opponent!.username}');
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Connection Status Indicator
                    if (_isConnecting)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.orange[100],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange[700]!,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Connecting to server...',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_isConnected && !_isConnecting)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.green[100],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Connected',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Searching Animation - only show if opponent not found
                            if (!opponentFound) _buildSearchingAnimation(),
                            if (!opponentFound) const SizedBox(height: 40),

                            // Current Player Card
                            _buildPlayerCard(
                              name: widget.currentPlayerName,
                              initial: widget.currentPlayerInitial,
                              color: widget.currentPlayerColor,
                              isCurrentPlayer: true,
                            ),
                            const SizedBox(height: 24),

                            // VS Text
                            const BBText(
                              data: 'VS',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: BBColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Opponent Card
                            _buildPlayerCard(
                              name:
                                  opponentFound && currentRoom?.opponent != null
                                      ? currentRoom!.opponent!.username
                                      : 'Searching...',
                              initial:
                                  opponentFound && currentRoom?.opponent != null
                                      ? currentRoom!.opponent!.username[0]
                                          .toUpperCase()
                                      : '?',
                              color:
                                  opponentFound
                                      ? BBColors.primaryColor
                                      : Colors.grey,
                              isCurrentPlayer: false,
                            ),
                            const SizedBox(height: 40),

                            // Status Message
                            _buildStatusMessage(opponentFound),

                            // Invitation Code (if applicable)
                            if (widget.matchType == MatchType.invitation &&
                                widget.invitationCode != null)
                              _buildInvitationCodeSection(),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons (Cancel and Ready)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _isConnected
                                      ? () => _handleCancel(context)
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[400],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey[300],
                              ),
                              child: BBText(
                                data: 'Cancel',
                                style: TextStyle(
                                  color:
                                      _isConnected
                                          ? Colors.white
                                          : Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Ready Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  opponentFound && _isConnected
                                      ? () => _handleReady(context)
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BBColors.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey[300],
                              ),
                              child: BBText(
                                data: 'Ready',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
              child: Icon(Icons.search, size: 40, color: BBColors.primaryColor),
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
                    color: Colors.black87,
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
          if (!isCurrentPlayer)
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
      message = 'Opponent found! Click Ready when you\'re prepared';
    } else if (widget.matchType == MatchType.random) {
      message = 'Searching for an opponent...';
    } else {
      message = 'Share the code below with your friend';
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
          if (!_isConnecting)
            Icon(
              opponentFound
                  ? Icons.check_circle
                  : widget.matchType == MatchType.random
                  ? Icons.search
                  : Icons.share,
              size: 20,
              color: opponentFound ? Colors.green : BBColors.primaryColor,
            ),
          if (!_isConnecting) const SizedBox(width: 8),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const BBText(
            data: 'Invitation Code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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

    if (state is BattleSearching) {
      roomId = state.room.roomId;
    } else if (state is BattleRoomCreated) {
      roomId = state.room.roomId;
    } else if (state is BattleOpponentFound) {
      roomId = state.room.roomId;
    } else if (state is BattleReady) {
      roomId = state.room.roomId;
    }

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
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: BBText(
                      data: 'Cancel Match?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: BBColors.borderGray),
                  BBText(
                    data: 'Are you sure you want to cancel this match?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      buildStudyModeButton(
                        context,
                        label: 'No',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 20),
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
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.95, -0.145),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 0.5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleReady(BuildContext context) {
    final state = context.read<BattleBloc>().state;
    String? roomId;

    if (state is BattleOpponentFound) {
      roomId = state.room.roomId;
    } else if (state is BattleSearching) {
      roomId = state.room.roomId;
    } else if (state is BattleRoomCreated) {
      roomId = state.room.roomId;
    } else if (state is BattleReady) {
      roomId = state.room.roomId;
    }

    if (roomId != null) {
      // Dispatch ready event to BattleBloc
      context.read<BattleBloc>().add(MarkReadyEvent(roomId: roomId));
    }
  }

  void _navigateToBattleScreen(BuildContext context, BattleInProgress state) {
    // Navigate to battle screen
    // TODO: You will handle navigation to quiz screen here
    print('Battle started! Navigate to quiz screen');
  }
}
