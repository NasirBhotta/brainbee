import 'package:brainbee/presentation/views/class/UI/DI/class_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/class/UI/bb_class_details.dart';
import 'package:brainbee/presentation/views/class/bloc/class_bloc.dart';
import 'package:brainbee/presentation/views/class/models/class_models.dart';

/// Entry point widget - wraps with dependency provider
class BBClassPage extends StatelessWidget {
  const BBClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClassDependencyProvider(child: const BBClass());
  }
}

/// Main class list screen
class BBClass extends StatefulWidget {
  const BBClass({super.key});

  @override
  State<BBClass> createState() => _BBClassState();
}

class _BBClassState extends State<BBClass> {
  @override
  void initState() {
    super.initState();
    // Dispatch event after frame is built to ensure bloc is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassBloc>().add(const FetchMyClassesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        title: BBText(
          data: 'My Classes',
          style: context.textStyle.titleMedium?.copyWith(),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ClassBloc, ClassState>(
        builder: (context, state) {
          if (state is ClassLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  BBColors.secondaryColor,
                ),
              ),
            );
          }

          if (state is ClassRefreshing) {
            return _buildClassList(
              context,
              state.previousClasses,
              isRefreshing: true,
            );
          }

          if (state is ClassError) {
            return _buildErrorState(context, state);
          }

          if (state is ClassEmpty) {
            return _buildNoClassesState(context);
          }

          if (state is ClassLoadSuccess) {
            return _buildClassList(context, state.classes);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildClassList(
    BuildContext context,
    List<ClassModel> classes, {
    bool isRefreshing = false,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ClassBloc>().add(const RefreshMyClassesEvent());
        await context.read<ClassBloc>().stream.firstWhere(
          (state) => state is! ClassRefreshing,
        );
      },
      color: BBColors.secondaryColor,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BBText(
                data: 'Enrolled Classes',
                style: context.textStyle.titleMedium?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ...classes.map(
                (classItem) => _buildClassCard(context, classItem),
              ),
            ],
          ),
          if (isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    BBColors.secondaryColor,
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classItem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ClassDetailScreen(
                  classItem: classItem.toEnrolledClass(),
                  classId: classItem.id,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: _getSubjectColor(classItem.subject),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Center(
                child: BBText(
                  data: classItem.subject.toUpperCase(),
                  style: context.textStyle.titleSmall?.copyWith(
                    color: BBColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BBText(
                    data: classItem.name,
                    style: context.textStyle.titleMedium?.copyWith(
                      color: BBColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  BBText(
                    data: 'Teacher: ${classItem.teacher.fullName}',
                    style: context.textStyle.bodyMedium?.copyWith(
                      color: BBColors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  BBText(
                    data: classItem.schedule,
                    style: context.textStyle.bodySmall?.copyWith(
                      color: BBColors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  BBText(
                    data: 'Grade ${classItem.grade}',
                    style: context.textStyle.bodySmall?.copyWith(
                      color: BBColors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildProgressIndicator(
                            classItem.completedAssignments,
                            classItem.totalAssignments,
                          ),
                          const SizedBox(width: 10),
                          BBText(
                            data:
                                '${classItem.completedAssignments}/${classItem.totalAssignments}',
                            style: context.textStyle.bodySmall?.copyWith(
                              color: BBColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: BBColors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: BBText(
                          data: 'View',
                          style: context.textStyle.bodySmall?.copyWith(
                            color: BBColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int completed, int total) {
    double progress = total > 0 ? completed / total : 0;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: BBColors.white.withOpacity(0.1),
      ),
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 3,
        backgroundColor: BBColors.white.withOpacity(0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(BBColors.white),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return BBColors.progressColor1;
      case 'science':
      case 'physics':
      case 'chemistry':
      case 'biology':
      case 'bio':
        return BBColors.progressColor2;
      case 'english':
        return BBColors.progressColor3;
      case 'history':
        return BBColors.progressColor4;
      default:
        return BBColors.progressColor4;
    }
  }

  Widget _buildNoClassesState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.school_outlined,
            size: 80,
            color: BBColors.disabledText,
          ),
          const SizedBox(height: 16),
          Text(
            'You are not enrolled in any classes',
            style: context.textStyle.titleMedium?.copyWith(
              color: BBColors.bodyText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check out available classes to enroll',
            style: context.textStyle.bodyMedium?.copyWith(
              color: BBColors.disabledText,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: BBText(
              data: 'Browse Classes',
              style: context.textStyle.labelLarge?.copyWith(
                color: BBColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ClassError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isNetworkError ? Icons.wifi_off : Icons.error_outline,
              size: 80,
              color: BBColors.alertRed,
            ),
            const SizedBox(height: 16),
            BBText(
              data:
                  state.isNetworkError
                      ? 'No Internet Connection'
                      : 'Failed to Load Classes',
              style: context.textStyle.titleMedium?.copyWith(
                color: BBColors.darkHeading,
              ),
            ),
            const SizedBox(height: 8),
            BBText(
              data: state.message,
              style: context.textStyle.bodyMedium?.copyWith(
                color: BBColors.bodyText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BBColors.bodyText,
                    side: const BorderSide(color: BBColors.borderGray),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: BBText(
                    data: 'Cancel',
                    style: context.textStyle.labelLarge?.copyWith(
                      color: BBColors.bodyText,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      () => context.read<ClassBloc>().add(
                        const FetchMyClassesEvent(),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BBColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: BBText(
                    data: 'Retry',
                    style: context.textStyle.labelLarge?.copyWith(
                      color: BBColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
