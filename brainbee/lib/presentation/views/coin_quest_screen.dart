import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/quest_model.dart';
import '../../core/widgets/quest_card.dart';
import '../../core/widgets/wallet_display.dart';
import '../bloc/quest_bloc.dart';

class CoinQuestScreen extends StatefulWidget {
  const CoinQuestScreen({super.key});

  @override
  State<CoinQuestScreen> createState() => _CoinQuestScreenState();
}

class _CoinQuestScreenState extends State<CoinQuestScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _claimingQuestId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<QuestBloc>().add(LoadQuests());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Coin Quests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<QuestBloc>().add(RefreshQuests());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'One-time'),
          ],
        ),
      ),
      body: BlocConsumer<QuestBloc, QuestState>(
        listener: (context, state) {
          if (state is QuestClaimed) {
            _claimingQuestId = null;
            _showSuccessDialog(state.claimedQuest, state.coinsEarned);
          } else if (state is QuestClaiming) {
            _claimingQuestId = state.claimingQuestId;
          } else if (state is QuestError) {
            _claimingQuestId = null;
            _showErrorDialog(state.message);
          }
        },
        builder: (context, state) {
          if (state is QuestLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            );
          }

          if (state is QuestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuestBloc>().add(LoadQuests());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is QuestLoaded || state is QuestClaiming || state is QuestClaimed) {
            final quests = _getQuestsFromState(state);
            final wallet = _getWalletFromState(state);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<QuestBloc>().add(RefreshQuests());
              },
              child: Column(
                children: [
                  WalletDisplay(wallet: wallet),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildQuestList(quests, QuestType.daily),
                        _buildQuestList(quests, QuestType.weekly),
                        _buildQuestList(quests, QuestType.oneTime),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildQuestList(List<Quest> allQuests, QuestType type) {
    final quests = allQuests.where((quest) => quest.type == type).toList();

    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForType(type),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_getTypeDisplayName(type)} quests available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new quests!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        final isLoading = _claimingQuestId == quest.id;

        return QuestCard(
          quest: quest,
          isLoading: isLoading,
          onClaimPressed: quest.isClaimable
              ? () => _showClaimConfirmation(quest)
              : null,
        );
      },
    );
  }

  void _showClaimConfirmation(Quest quest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Claim Reward',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/coin.png',
                width: 64,
                height: 64,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 64,
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to claim ${quest.coinReward} coins for completing "${quest.title}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<QuestBloc>().add(ClaimQuest(quest.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Claim'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(Quest quest, int coinsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+$coinsEarned coins added to your wallet!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  quest.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Awesome!'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<Quest> _getQuestsFromState(QuestState state) {
    if (state is QuestLoaded) return state.quests;
    if (state is QuestClaiming) return state.quests;
    if (state is QuestClaimed) return state.quests;
    return [];
  }

  Wallet _getWalletFromState(QuestState state) {
    if (state is QuestLoaded) return state.wallet;
    if (state is QuestClaiming) return state.wallet;
    if (state is QuestClaimed) return state.wallet;
    return Wallet.empty('default_student');
  }

  IconData _getIconForType(QuestType type) {
    switch (type) {
      case QuestType.daily:
        return Icons.today;
      case QuestType.weekly:
        return Icons.calendar_view_week;
      case QuestType.oneTime:
        return Icons.stars;
    }
  }

  String _getTypeDisplayName(QuestType type) {
    switch (type) {
      case QuestType.daily:
        return 'daily';
      case QuestType.weekly:
        return 'weekly';
      case QuestType.oneTime:
        return 'one-time';
    }
  }
}