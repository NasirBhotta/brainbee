import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/widgets/popups/bb_enter_invitation_code.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_book_selection.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_searching_players.dart';
import 'package:brainbee/presentation/views/learn/battle/bloc/battle_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Helper class to store pending invitation data
class _PendingInvitationData {
  final String playerName;
  final String playerInitial;
  final String invitationCode;

  _PendingInvitationData({
    required this.playerName,
    required this.playerInitial,
    required this.invitationCode,
  });
}

class BBBattle extends StatefulWidget {
  final StudentState? state;
  const BBBattle({super.key, this.state});

  @override
  State<BBBattle> createState() => _BBBattleState();
}

class _BBBattleState extends State<BBBattle> {
  dynamic battleStats;
  List<dynamic> battleHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Use addPostFrameCallback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BattleBloc>().add(const FetchBattleStatsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        toolbarHeight: context.screenHeight * 0.05,
        backgroundColor: BBColors.white,
        title: BBText(
          data: "Battle",
          style: context.textStyle.titleMedium?.copyWith(color: BBColors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: BBColors.black),
        ),
      ),
      body: BlocConsumer<BattleBloc, BattleState>(
        listener: (context, state) {
          // Handle join battle response - navigate only on success
          if (_pendingInvitationData != null) {
            _dismissLoadingDialog();

            if (state is BattleOpponentFound || state is BattleSearching) {
              // Success! Now navigate
              final data = _pendingInvitationData!;
              _pendingInvitationData = null; // Clear pending data

              final room =
                  state is BattleOpponentFound
                      ? (state).room
                      : (state as BattleSearching).room;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (ctx) => BlocProvider.value(
                        value: context.read<BattleBloc>(),
                        child: BbSearchingPlayers(
                          matchType: MatchType.invitation,
                          currentPlayerName: data.playerName,
                          currentPlayerInitial: data.playerInitial,
                          currentPlayerColor: BBColors.primaryColor,
                          roomId: room.roomId,
                          invitationCode: data.invitationCode,
                        ),
                      ),
                ),
              );
            } else if (state is BattleError) {
              // Failed! Show error message
              _pendingInvitationData = null; // Clear pending data
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          // Update local state based on bloc state
          if (state is BattleStatsLoaded) {
            battleStats = state.stats;
          }
          if (state is BattleHistoryItemsLoaded) {
            battleHistory = state.history;
          }

          _isLoading = state is BattleLoading;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BattleBloc>().add(const FetchBattleStatsEvent());
              context.read<BattleBloc>().add(const FetchBattleHistoryEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    _buildPlayerStatsCard(context, battleStats, _isLoading),
                    const SizedBox(height: 16),
                    _buildBattleActionsContainer(context),
                    const SizedBox(height: 16),
                    _buildBattleHistorySection(
                      context,
                      battleHistory,
                      _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBattleActionsContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BBColors.primaryColor, BBColors.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BBColors.primaryColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Start Battle Button
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BBBookSelectionForBattle(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: BBColors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: BBColors.alertRed,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            BBText(
                              data: "Start the Battle",
                              style: context.textStyle.labelLarge?.copyWith(
                                color: BBColors.alertRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Enter Invitation Code Button - FIXED
                    InkWell(
                      onTap: () => _handleEnterInvitationCode(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.vpn_key,
                              color: BBColors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            BBText(
                              data: "Enter Invitation Code",
                              style: context.textStyle.labelMedium?.copyWith(
                                color: BBColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: -context.screenWidth * 0.015,
            top: -20,
            bottom: -20,
            child: Transform.rotate(
              angle: 0.2,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset("assets/crown.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIX: Separate method to handle invitation code flow
  Future<void> _handleEnterInvitationCode(BuildContext context) async {
    // Store references BEFORE showing dialog
    final battleBloc = context.read<BattleBloc>();

    // Get student data safely - provide defaults if not available
    String playerName = "Guest Player";
    String playerInitial = "G";

    if (widget.state != null && widget.state is StudentDataLoaded) {
      final user = (widget.state as StudentDataLoaded).student;
      playerName = "${user.firstName} ${user.lastName}";
      playerInitial =
          user.firstName.isNotEmpty
              ? user.firstName.substring(0, 1).toUpperCase()
              : "G";
    }

    // Show popup and get code
    final String? invitationCode = await showInvitationCodePopUp(context);

    // Check if widget is still mounted after async operation
    if (!mounted) return;

    if (invitationCode != null && invitationCode.length == 6) {
      // Show loading indicator
      _showLoadingDialog(context);

      // Dispatch event using stored reference
      battleBloc.add(JoinBattleRoomEvent(invitationCode: invitationCode));

      // Wait for state change and handle navigation in listener
      // Store data for use in listener
      _pendingInvitationData = _PendingInvitationData(
        playerName: playerName,
        playerInitial: playerInitial,
        invitationCode: invitationCode,
      );
    }
  }

  // Store pending invitation data
  _PendingInvitationData? _pendingInvitationData;

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _dismissLoadingDialog() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // ... rest of the widget methods remain the same
  Widget _buildPlayerStatsCard(
    BuildContext context,
    dynamic battleStats,
    bool isLoading,
  ) {
    // Get student data safely
    String playerName = "Guest";
    String playerInitial = "G";

    if (widget.state != null && widget.state is StudentDataLoaded) {
      final student = (widget.state as StudentDataLoaded).student;
      playerName = "${student.firstName} ${student.lastName}";
      playerInitial =
          student.firstName.isNotEmpty
              ? student.firstName.substring(0, 1).toUpperCase()
              : "G";
    }

    if (isLoading && battleStats == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BBColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  BBColors.primaryColor.withOpacity(0.1),
                  BBColors.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [BBColors.primaryColor, BBColors.secondaryColor],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        battleStats?.avatarColor ?? Colors.green[700],
                    child: BBText(
                      data: battleStats?.initial ?? playerInitial,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: BBColors.white,
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
                        data: playerName,
                        style: context.textStyle.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BBColors.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: BBColors.primaryColor,
                            ),
                            SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.emoji_events,
                    label: "Wins",
                    value: battleStats?.wins?.toString() ?? "0",
                    color: Colors.green,
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.sports_mma,
                    label: "Battles",
                    value: battleStats?.totalBattles?.toString() ?? "0",
                    color: Colors.blue,
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.monetization_on,
                    label: "Coins",
                    value: battleStats?.coinsCollected?.toString() ?? "0",
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        BBText(
          data: value,
          style: context.textStyle.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        BBText(
          data: label,
          style: context.textStyle.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBattleHistorySection(
    BuildContext context,
    List<dynamic> battleHistory,
    bool isLoading,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: BBColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: BBColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    BBText(
                      data: "Battle History",
                      style: context.textStyle.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (battleHistory.isNotEmpty || battleHistory != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BBColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: BBText(
                      data: "${battleHistory.length}",
                      style: context.textStyle.labelSmall?.copyWith(
                        color: BBColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading && battleHistory.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          else if (battleHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.sports_kabaddi, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  BBText(
                    data: "No battle history yet",
                    style: context.textStyle.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  BBText(
                    data: "Start your first battle!",
                    style: context.textStyle.labelSmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: context.screenHeight * 0.4,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: battleHistory.length,
                separatorBuilder:
                    (_, __) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final battle = battleHistory[index];
                  return _buildBattleHistoryItem(context, battle, index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBattleHistoryItem(
    BuildContext context,
    dynamic battle,
    int index,
  ) {
    final colors = [
      Colors.red[700],
      Colors.blue[700],
      Colors.green[700],
      Colors.orange[700],
      Colors.purple[700],
      Colors.brown[700],
      Colors.teal[700],
      Colors.pink[700],
      Colors.indigo[700],
      Colors.cyan[700],
    ];
    final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    final isWin = battle?.result == 'win';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isWin ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: colors[index % colors.length],
          child: BBText(
            data: battle?.opponentInitial ?? letters[index % letters.length],
            style: context.textStyle.titleMedium?.copyWith(
              color: BBColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: BBText(
        data: battle?.opponentUsername ?? "@Username",
        style: context.textStyle.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: BBText(
        data: battle?.date ?? "Today",
        style: context.textStyle.labelSmall?.copyWith(color: Colors.grey[600]),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isWin
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: BBText(
          data: isWin ? "Won" : "Lost",
          style: context.textStyle.labelSmall?.copyWith(
            color: isWin ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
