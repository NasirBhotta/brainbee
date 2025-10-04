// lib/presentation/views/extras/leaderboard/bb_leaderboard.dart

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_customgraph.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_segmented_toggle.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bloc/leaderboard_event.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bloc/leaderboard_state.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/models/bb_leaderboard_model.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/repo/bb_leaderboard_repo_impl.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/services/bb_leaderboard_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Main entry point with BlocProvider
class BBleaderBoard extends StatelessWidget {
  const BBleaderBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => LeaderboardBloc(
            repository: LeaderboardRepositoryImpl(
              apiService: LeaderboardApiService(),
            ),
          ),
      child: const _BBleaderBoardView(),
    );
  }
}

// Internal view widget
class _BBleaderBoardView extends StatefulWidget {
  const _BBleaderBoardView();

  @override
  State<_BBleaderBoardView> createState() => _BBleaderBoardViewState();
}

class _BBleaderBoardViewState extends State<_BBleaderBoardView> {
  TimeToggleOption selectedOption = TimeToggleOption.weekly;

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    context.read<LeaderboardBloc>().add(const FetchLeaderboard(type: 'weekly'));
  }

  String _getTypeFromOption(TimeToggleOption option) {
    switch (option) {
      case TimeToggleOption.weekly:
        return 'weekly';
      case TimeToggleOption.monthly:
        return 'monthly';
      case TimeToggleOption.overall:
        return 'overall';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: BBColors.borderGray, height: 1),
        ),
        title: BBText(
          data: "LeaderBoard",
          style: context.textStyle.titleMedium,
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                BBColors.secondaryColor,
              ),
            ),
          );
        }

        if (state is LeaderboardError) {
          return _buildErrorState(state.message);
        }

        if (state is LeaderboardLoaded) {
          return _buildLeaderboardList(state.data);
        }

        return const Center(child: Text('No data available'));
      },
    );
  }

  Widget _buildLeaderboardList(LeaderboardData data) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LeaderboardBloc>().add(
          RefreshLeaderboard(type: _getTypeFromOption(selectedOption)),
        );
      },
      child: ListView(
        children: [
          BBSegmentedToggle(
            onOptionSelected: (timeToggleOption) {
              setState(() {
                selectedOption = timeToggleOption;
              });
              context.read<LeaderboardBloc>().add(
                FetchLeaderboard(type: _getTypeFromOption(timeToggleOption)),
              );
            },
            initialOption: selectedOption,
          ),
          // Only show podium if we have at least 3 entries
          if (data.leaderboard.length >= 3) ...[
            SizedBox(
              height: context.screenHeight * 0.5,
              child: PodiumScreen(
                data:
                    data.leaderboard
                        .where((entry) => entry.rank >= 1 && entry.rank <= 3)
                        .toList(),
              ),
            ),
          ] else if (data.leaderboard.isEmpty) ...[
            const SizedBox(height: 100),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  BBText(
                    data: 'No leaderboard data available',
                    style: context.textStyle.titleMedium?.copyWith(
                      color: BBColors.disabledText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
          // Show all entries in list
          ...data.leaderboard.map((entry) {
            return _buildListTile(entry);
          }),
        ],
      ),
    );
  }

  Widget _buildListTile(LeaderboardEntry item) {
    int position = item.rank;
    bool isTopThree = position <= 3;

    IconData crownIcon;
    Color crownColor;

    if (position == 1) {
      crownIcon = Icons.emoji_events;
      crownColor = Colors.amber;
    } else if (position == 2) {
      crownIcon = Icons.emoji_events;
      crownColor = Colors.grey;
    } else if (position == 3) {
      crownIcon = Icons.emoji_events;
      crownColor = Colors.brown;
    } else {
      crownIcon = Icons.emoji_events_outlined;
      crownColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 233, 232, 232),
              shape: BoxShape.circle,
              boxShadow: [
                if (position <= 3)
                  const BoxShadow(
                    color: BBColors.lightGrayBG,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: BBText(
              data: "$position",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BBColors.bodyText,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 28,
            backgroundColor: BBColors.secondaryColor.withOpacity(0.2),
            backgroundImage:
                item.profilePic != null && item.profilePic!.isNotEmpty
                    ? NetworkImage(item.profilePic!)
                    : null,
            child:
                item.profilePic == null || item.profilePic!.isEmpty
                    ? Text(
                      item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                      style: context.textStyle.titleLarge?.copyWith(
                        color: BBColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BBText(
                  data: item.name,
                  style: context.textStyle.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                BBText(
                  data: "${item.score} points",
                  style: context.textStyle.labelMedium?.copyWith(
                    color: BBColors.disabledText,
                  ),
                ),
              ],
            ),
          ),
          if (isTopThree) Icon(crownIcon, color: crownColor, size: 28),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          BBText(
            data: 'Error loading leaderboard',
            style: context.textStyle.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BBText(
              data: message,
              style: context.textStyle.bodyMedium?.copyWith(
                color: BBColors.disabledText,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<LeaderboardBloc>().add(
                FetchLeaderboard(type: _getTypeFromOption(selectedOption)),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
