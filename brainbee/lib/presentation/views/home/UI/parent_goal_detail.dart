import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/home/UI/parentGoal/bloc/parentgoals_bloc.dart';
import 'package:brainbee/presentation/views/home/UI/parentGoal/models/parent_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// Import your parent goals bloc and model

class ParentGoalDetailScreen extends StatelessWidget {
  final ParentGoal goal;

  const ParentGoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentGoalsBloc(),
      child: _ParentGoalDetailView(goal: goal),
    );
  }
}

class _ParentGoalDetailView extends StatelessWidget {
  final ParentGoal goal;

  const _ParentGoalDetailView({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BBText(
          data: 'Goal Details',
          style: context.textStyle.titleMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[300]),
        ),
      ),
      body: BlocConsumer<ParentGoalsBloc, ParentGoalsState>(
        listener: (context, state) {
          if (state is ParentGoalMarkedComplete) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Wait a bit then navigate back
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            });
          } else if (state is ParentGoalMarkCompleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isProcessing = state is ParentGoalMarkingComplete;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            goal.isCompleted
                                ? Colors.green[100]
                                : Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            goal.isCompleted
                                ? Icons.check_circle
                                : Icons.pending,
                            color:
                                goal.isCompleted
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          BBText(
                            data: goal.isCompleted ? 'Completed' : 'Pending',
                            style: context.textStyle.bodyMedium?.copyWith(
                              color:
                                  goal.isCompleted
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Goal Icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color:
                            goal.isCompleted
                                ? Colors.green[100]
                                : Colors.orange[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        goal.isCompleted ? Icons.emoji_events : Icons.flag,
                        size: 50,
                        color:
                            goal.isCompleted
                                ? Colors.green[700]
                                : Colors.orange[700],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Goal Title
                  BBText(
                    data: 'Goal Title',
                    style: context.textStyle.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: BBText(
                      data: goal.title,
                      style: context.textStyle.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Goal Description
                  BBText(
                    data: 'Description',
                    style: context.textStyle.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: BBText(
                      data: goal.description,
                      style: context.textStyle.bodyMedium,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Assigned By
                  BBText(
                    data: 'Assigned By',
                    style: context.textStyle.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Icon(Icons.person, color: Colors.blue[700]),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BBText(
                              data: goal.parentId.fullName,
                              style: context.textStyle.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            BBText(
                              data: goal.parentId.role.toUpperCase(),
                              style: context.textStyle.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date Information
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'Created',
                          value: DateFormat(
                            'MMM dd, yyyy',
                          ).format(goal.createdAt),
                          icon: Icons.calendar_today,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          label: goal.isCompleted ? 'Completed' : 'Updated',
                          value: DateFormat(
                            'MMM dd, yyyy',
                          ).format(goal.completedAt ?? goal.updatedAt),
                          icon:
                              goal.isCompleted
                                  ? Icons.check_circle
                                  : Icons.update,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Mark Complete Button
                  if (!goal.isCompleted)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                            isProcessing
                                ? null
                                : () {
                                  _showConfirmationDialog(context);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child:
                            isProcessing
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline),
                                    const SizedBox(width: 8),
                                    BBText(
                                      data: 'Mark as Complete',
                                      style: context.textStyle.bodyLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                      ),
                    ),

                  if (goal.isCompleted && goal.completedAt != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.celebration, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BBText(
                                  data: 'Congratulations! 🎉',
                                  style: context.textStyle.bodyMedium?.copyWith(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                BBText(
                                  data:
                                      'You completed this goal on ${DateFormat('MMM dd, yyyy').format(goal.completedAt!)}',
                                  style: context.textStyle.bodySmall?.copyWith(
                                    color: Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Mark Goal as Complete'),
            content: const Text(
              'Are you sure you want to mark this goal as complete? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<ParentGoalsBloc>().add(
                    MarkParentGoalComplete(goal.id),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              BBText(
                data: label,
                style: context.textStyle.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BBText(
            data: value,
            style: context.textStyle.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
