import 'package:brainbee/core/widgets/quests/claim_dialog.dart';
import 'package:brainbee/core/widgets/quests/quest_card.dart';
import 'package:brainbee/core/widgets/wallet/bb_wallet.dart';
import 'package:brainbee/presentation/views/extras/coinquests/bloc/quest_event.dart';
import 'package:brainbee/presentation/views/extras/coinquests/bloc/quest_state.dart';
import 'package:brainbee/presentation/views/extras/coinquests/models/quest.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quest_bloc.dart';

class BBCoinQuestScreen extends StatefulWidget {
  final String userId;

  const BBCoinQuestScreen({super.key, required this.userId});

  @override
  State<BBCoinQuestScreen> createState() => _BBCoinQuestScreenState();
}

class _BBCoinQuestScreenState extends State<BBCoinQuestScreen> {
  late QuestBloc _questBloc;
  @override
  void initState() {
    super.initState();
    _questBloc = context.read<QuestBloc>();
    _questBloc.add(LoadQuests(widget.userId));
    _questBloc.add(StartQuestPolling(widget.userId));
  }

  @override
  void dispose() {
    _questBloc.add(StopQuestPolling());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        title: Text(
          'Coin Quests',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: BBColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: BBColors.secondaryColor,
        iconTheme: const IconThemeData(color: BBColors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: BBColors.white, size: 20),
            onPressed: () {
              context.read<QuestBloc>().add(RefreshQuests(widget.userId));
            },
          ),
        ],
      ),
      body: BlocConsumer<QuestBloc, QuestState>(
        listener: (context, state) {
          if (!mounted) {
            return;
          }
          if (state is QuestClaimed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '+${state.coinsAdded} Coins added to your Wallet!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BBColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: BBColors.successGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is QuestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BBColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: BBColors.alertRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QuestLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  BBColors.primaryColor,
                ),
              ),
            );
          } else if (state is QuestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: BBColors.alertRed),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: BBColors.darkHeading,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuestBloc>().add(LoadQuests(widget.userId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BBColors.primaryColor,
                      foregroundColor: BBColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: BBColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is QuestLoaded ||
              state is QuestClaiming ||
              state is QuestClaimed) {
            final quests =
                state is QuestLoaded
                    ? state.quests
                    : state is QuestClaiming
                    ? state.quests
                    : (state as QuestClaimed).quests;

            final wallet =
                state is QuestLoaded
                    ? state.wallet
                    : state is QuestClaiming
                    ? state.wallet
                    : (state as QuestClaimed).wallet;

            return Column(
              children: [
                WalletWidget(wallet: wallet),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<QuestBloc>().add(
                        RefreshQuests(widget.userId),
                      );
                    },
                    color: BBColors.primaryColor,
                    backgroundColor: BBColors.white,
                    child: ListView(
                      padding: const EdgeInsets.all(14),
                      children: [
                        _buildQuestSection(
                          'Daily Quests',
                          quests
                              .where((q) => q.type == QuestType.daily)
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        _buildQuestSection(
                          'Weekly Quests',
                          quests
                              .where((q) => q.type == QuestType.weekly)
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        _buildQuestSection(
                          'One-Time Quests',
                          quests
                              .where((q) => q.type == QuestType.oneTime)
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_outline,
                  size: 48,
                  color: BBColors.primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome to Coin Quests!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete quests to earn coins',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestSection(String title, List<Quest> quests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BBColors.primaryColor.withOpacity(0.1),
                BBColors.secondaryColor.withOpacity(0.1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: BBColors.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: BBColors.darkHeading,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (quests.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BBColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: BBColors.borderGray, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 36,
                  color: BBColors.disabledText,
                ),
                const SizedBox(height: 8),
                Text(
                  'No quests available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BBColors.disabledText,
                  ),
                ),
              ],
            ),
          )
        else
          ...quests.map(
            (quest) => QuestCard(
              quest: quest,
              onClaim: () => _showClaimDialog(quest),
              isLoading:
                  context.read<QuestBloc>().state is QuestClaiming &&
                  (context.read<QuestBloc>().state as QuestClaiming)
                          .claimingQuestId ==
                      quest.id,
            ),
          ),
      ],
    );
  }

  void _showClaimDialog(Quest quest) {
    showDialog(
      context: context,
      builder:
          (context) => ClaimDialog(
            quest: quest,
            onConfirm: () {
              Navigator.of(context).pop();
              context.read<QuestBloc>().add(ClaimQuest(widget.userId, quest));
            },
          ),
    );
  }
}
