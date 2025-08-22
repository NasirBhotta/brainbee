// lib/screens/badges_screen.dart
import 'package:brainbee/core/constants/badge_constants.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/badge_utills/badge_utills.dart';
import 'package:brainbee/core/widgets/badges/badge_category_section.dart';
import 'package:brainbee/core/widgets/badges/badge_detail_dialog.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/bloc/badge_bloc.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/bloc/badge_event.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/bloc/badge_state.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgesScreen extends StatefulWidget {
  final String studentId;

  const BadgesScreen({super.key, required this.studentId});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    // Load badges when screen initializes
    context.read<BadgeBloc>().add(LoadBadges(studentId: widget.studentId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        title: Text(
          'Badges',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: BBColors.white,
          ),
        ),
        backgroundColor: BBColors.secondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: BBColors.white),
        actions: [
          BlocBuilder<BadgeBloc, BadgeState>(
            builder: (context, state) {
              if (state is BadgeLoaded || state is BadgeRefreshing) {
                return IconButton(
                  onPressed: () {
                    context.read<BadgeBloc>().add(
                      RefreshBadges(studentId: widget.studentId),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh badges',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: BlocBuilder<BadgeBloc, BadgeState>(
            builder: (context, state) {
              if (state is BadgeLoaded || state is BadgeRefreshing) {
                return Container(
                  color: BBColors.secondaryColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: BBColors.white,
                    labelColor: BBColors.white,
                    unselectedLabelColor: BBColors.white.withOpacity(0.7),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.grid_view, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'All (${state is BadgeLoaded ? state.totalBadgesCount : (state as BadgeRefreshing).totalBadgesCount})',
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Earned (${state is BadgeLoaded ? state.earnedBadgesCount : (state as BadgeRefreshing).earnedBadgesCount})',
                            ),
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
        ),
      ),
      body: BlocBuilder<BadgeBloc, BadgeState>(
        builder: (context, state) {
          if (state is BadgeLoading) {
            return _buildLoadingState();
          } else if (state is BadgeError) {
            return _buildErrorState(state);
          } else if (state is BadgeLoaded || state is BadgeRefreshing) {
            final badges =
                state is BadgeLoaded
                    ? state.badges
                    : (state as BadgeRefreshing).currentBadges;
            final categorizedBadges =
                state is BadgeLoaded
                    ? state.categorizedBadges
                    : (state as BadgeRefreshing).categorizedBadges;
            final hasEarnedBadges =
                state is BadgeLoaded
                    ? state.hasEarnedBadges
                    : (state as BadgeRefreshing).hasEarnedBadges;

            return Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllBadgesTab(categorizedBadges),
                    _buildEarnedBadgesTab(badges, hasEarnedBadges),
                  ],
                ),
                if (state is BadgeRefreshing)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 3,
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          BBColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
          return _buildInitialState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading badges...',
            style: GoogleFonts.poppins(fontSize: 14, color: BBColors.bodyText),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BadgeError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isNetworkError ? Icons.wifi_off : Icons.error_outline,
              size: 56,
              color: BBColors.alertRed,
            ),
            const SizedBox(height: 16),
            Text(
              state.isNetworkError ? 'Connection Error' : 'Error',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: BBColors.darkHeading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: BBColors.bodyText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BadgeBloc>().add(
                  RetryLoadBadges(studentId: widget.studentId),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                AppConstants.retryButtonText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.primaryColor,
                foregroundColor: BBColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Text(
        'Welcome to Badges!',
        style: GoogleFonts.poppins(fontSize: 16, color: BBColors.bodyText),
      ),
    );
  }

  Widget _buildAllBadgesTab(
    Map<BbBadgeCategory, List<BbBadge>> categorizedBadges,
  ) {
    if (categorizedBadges.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'No badges available',
        subtitle: 'Check back later for new badges!',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BadgeBloc>().add(
          RefreshBadges(studentId: widget.studentId),
        );
      },
      color: BBColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            _buildProgressCard(categorizedBadges),
            const SizedBox(height: 16),
            ...BbBadgeCategory.values.map((category) {
              final badges = categorizedBadges[category] ?? [];
              if (badges.isEmpty) return const SizedBox.shrink();

              return BadgeCategorySection(
                category: category,
                badges: BadgeUtils.sortBadgesWithinCategory(badges),
                onBadgeTap: _onBadgeTap,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnedBadgesTab(List<BbBadge> allBadges, bool hasEarnedBadges) {
    final earnedBadges = BadgeUtils.filterEarnedBadges(allBadges);

    if (!hasEarnedBadges) {
      return _buildEmptyState(
        icon: Icons.star_border,
        title: 'No earned badges yet',
        subtitle: AppConstants.noEarnedBadgesMessage,
      );
    }

    final categorizedEarnedBadges = BadgeUtils.groupBadgesByCategory(
      earnedBadges,
    );

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BadgeBloc>().add(
          RefreshBadges(studentId: widget.studentId),
        );
      },
      color: BBColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            _buildEarnedProgressCard(earnedBadges.length, allBadges.length),
            const SizedBox(height: 16),
            ...BbBadgeCategory.values.map((category) {
              final badges = categorizedEarnedBadges[category] ?? [];
              if (badges.isEmpty) return const SizedBox.shrink();

              return BadgeCategorySection(
                category: category,
                badges: BadgeUtils.sortBadgesWithinCategory(badges),
                onBadgeTap: _onBadgeTap,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    Map<BbBadgeCategory, List<BbBadge>> categorizedBadges,
  ) {
    final allBadges =
        categorizedBadges.values.expand((badges) => badges).toList();
    final earnedCount = BadgeUtils.filterEarnedBadges(allBadges).length;
    final totalCount = allBadges.length;
    final progressPercentage = BadgeUtils.getProgressPercentage(allBadges);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BBColors.primaryColor, BBColors.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: BBColors.primaryColor.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BBColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: BBColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Badge Progress',
                      style: GoogleFonts.poppins(
                        color: BBColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You\'ve earned $earnedCount out of $totalCount badges',
                      style: GoogleFonts.poppins(
                        color: BBColors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progressPercentage * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  color: BBColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: BBColors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(BBColors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnedProgressCard(int earnedCount, int totalCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BBColors.successGreen, BBColors.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: BBColors.successGreen.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BBColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.star, color: BBColors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earned Badges',
                  style: GoogleFonts.poppins(
                    color: BBColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  earnedCount == 1
                      ? 'You have earned 1 badge'
                      : 'You have earned $earnedCount badges',
                  style: GoogleFonts.poppins(
                    color: BBColors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$earnedCount',
            style: GoogleFonts.poppins(
              color: BBColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: BBColors.disabledText),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: BBColors.darkHeading,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: BBColors.bodyText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onBadgeTap(BbBadge badge) {
    if (badge.isEarned) {
      BadgeDetailDialog.show(context, badge);
    } else {
      _showUnearnedBadgeInfo(badge);
    }
  }

  void _showUnearnedBadgeInfo(BbBadge badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => UnearnedBadgeBottomSheet(badge: badge),
    );
  }
}

// lib/widgets/unearned_badge_bottom_sheet.dart
class UnearnedBadgeBottomSheet extends StatelessWidget {
  final BbBadge badge;

  const UnearnedBadgeBottomSheet({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: BBColors.borderGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Badge icon (locked)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: BBColors.lightGrayBG,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: BBColors.borderGray),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      BadgeUtils.getCategoryIcon(badge.category),
                      size: 32,
                      color: BBColors.disabledText,
                    ),
                  ),
                  Center(
                    child: Icon(Icons.lock, size: 28, color: BBColors.bodyText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Badge name
            Text(
              badge.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: BBColors.darkHeading,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Badge description
            Text(
              badge.description,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: BBColors.bodyText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // Earning criteria
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BBColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: BBColors.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: BBColors.secondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'How to earn this badge',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: BBColors.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge.earningCriteria,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: BBColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                  foregroundColor: BBColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Got it!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
