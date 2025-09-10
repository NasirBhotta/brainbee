import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoalOption {
  final String title;
  final String description;
  final int quizzes;
  final int minutes;

  GoalOption({
    required this.description,
    required this.title,
    required this.quizzes,
    required this.minutes,
  });
}

class BBEditGoals extends StatefulWidget {
  final StudentModel student;

  const BBEditGoals({super.key, required this.student});

  @override
  State<BBEditGoals> createState() => _BBEditGoalsState();
}

class _BBEditGoalsState extends State<BBEditGoals> {
  int _selectedGoalIndex = 0;
  bool _showNotifications = true;
  final TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  final List<DateTime> _reminderTimes = [];

  final List<GoalOption> _goalOptions = [
    GoalOption(
      title: 'Casual',
      description: '2 Quizzes & Estimate 7 minutes daily',
      quizzes: 2,
      minutes: 7,
    ),
    GoalOption(
      title: 'Regular',
      description: '6 Quizzes & Estimate 21 minutes daily',
      quizzes: 6,
      minutes: 21,
    ),
    GoalOption(
      title: 'Serious',
      description: '10 Quizzes & Estimate 35 minutes daily',
      quizzes: 10,
      minutes: 35,
    ),
    GoalOption(
      title: 'Epic',
      description: '14 Quizzes & Estimate 49 minutes daily',
      quizzes: 14,
      minutes: 49,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentUpdateGoalsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Goals updated successfully!')),
            );
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else if (state is StudentUpdateGoalsFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          if (state is StudentDataLoaded) {
            final student = state.student;
            _selectedGoalIndex = _goalOptions.indexWhere(
              (goal) => goal.title == student.goal.title,
            );
            _reminderTimes.clear();
            _reminderTimes.addAll(student.goal.reminder);
          }
          return SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          'Edit Daily Goals',
                          textAlign: TextAlign.center,
                          style: context.textStyle.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 48), // For balance
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Goal selection
                          BBText(
                            data: 'Pick a goal',
                            style: context.textStyle.titleSmall?.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Goal options
                          ...List.generate(_goalOptions.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedGoalIndex = index;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              _selectedGoalIndex == index
                                                  ? Colors.blue
                                                  : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child:
                                          _selectedGoalIndex == index
                                              ? Container(
                                                margin: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue,
                                                ),
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _goalOptions[index].title,
                                          style: context.textStyle.titleSmall,
                                        ),
                                        Text(
                                          '${_goalOptions[index].quizzes} Quizzes & Estimated ${_goalOptions[index].minutes} minutes daily',
                                          style: context.textStyle.titleSmall
                                              ?.copyWith(
                                                fontSize: 12,
                                                color: BBColors.disabledText,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 32),

                          // Reminder section
                          BBText(
                            data: 'When can we remind you?',
                            style: context.textStyle.titleSmall?.copyWith(
                              fontSize: 16,
                            ),
                          ),

                          BBText(
                            data: 'Pick days and time',
                            style: context.textStyle.titleSmall?.copyWith(
                              fontSize: 12,
                              color: BBColors.disabledText,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[300],
                          ),

                          const SizedBox(height: 16),

                          // Notifications toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BBText(
                                    data: 'Time Reminder Notification',
                                    style: context.textStyle.titleSmall
                                        ?.copyWith(
                                          fontSize: 12,
                                          color: BBColors.primaryBlue,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  BBText(
                                    data: 'Show Notifications',
                                    style: context.textStyle.titleSmall
                                        ?.copyWith(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  BBText(
                                    data: 'eg: Remind me on X time?',
                                    style: context.textStyle.titleSmall
                                        ?.copyWith(
                                          fontSize: 12,
                                          color: BBColors.disabledText,
                                        ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _showNotifications,
                                onChanged: (value) {
                                  setState(() {
                                    _showNotifications = value;
                                  });
                                },
                                activeColor: Colors.white,
                                activeTrackColor: Colors.blue,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Add reminder button
                          InkWell(
                            onTap: () {
                              _showAddReminderDialog();
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.green[400],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Add Reminder',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Time display
                          ...List.generate(_reminderTimes.length, (index) {
                            final reminderTime =
                                _reminderTimes[index]; // get time for this row

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Text(
                                          'We will remind you at this time',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _reminderTimes.removeAt(index);
                                          print(
                                            "reminders times are $_reminderTimes",
                                          );
                                        });
                                      },
                                    ),

                                    // Divider
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey[300],
                                ),
                              ],
                            );
                          }),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),

                // Save button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: context.screenWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [
                          BBColors.primaryColor,
                          BBColors.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<StudentBloc>().add(
                          StudentUpdateGoals(
                            goal: Goal(
                              value: _goalOptions[_selectedGoalIndex].quizzes,
                              status: false,
                              title: _goalOptions[_selectedGoalIndex].title,
                              description:
                                  _goalOptions[_selectedGoalIndex].description,
                              reminder: _reminderTimes,
                              dueDate: DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                23,
                                59,
                                59,
                              ),
                              noOfAttempts: widget.student.goal.noOfAttempts,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child:
                          (state is StudentDataLoading)
                              ? CircularProgressIndicator(
                                color: BBColors.white,
                                strokeWidth: 1,
                              )
                              : Text(
                                'Save',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: BBColors.white,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddReminderDialog() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      DateTime now = DateTime.now();

      // Convert selectedTime into today's DateTime
      DateTime reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // If the selected time is before current time, set for tomorrow
      if (reminderDateTime.isBefore(now)) {
        reminderDateTime = reminderDateTime.add(const Duration(days: 1));
      }

      setState(() {
        _reminderTimes.add(
          reminderDateTime,
        ); // <-- store DateTime instead of TimeOfDay
      });

      print("Reminder set for: $reminderDateTime");
    }
  }
}
