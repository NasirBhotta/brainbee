import 'package:brainbee/services/goalNotificationPrefrences/bb_goal_notification_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/services/bb_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

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

class _BBEditGoalsState extends State<BBEditGoals> with WidgetsBindingObserver {
  int _selectedGoalIndex = 0;
  bool _goalNotificationsEnabled = false;
  final List<DateTime> _reminderTimes = [];
  bool _isInitialized = false;
  bool _hasSystemPermission = false;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGoalNotificationPreference();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Only check system permission when app resumes
    if (state == AppLifecycleState.resumed && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _checkSystemPermission();
        }
      });
    }
  }

  /// Load goal notification preference from local storage
  Future<void> _loadGoalNotificationPreference() async {
    if (!mounted) return;

    try {
      final goalPref =
          await GoalNotificationPreferences.isGoalNotificationEnabled();
      final systemPerm =
          await GoalNotificationPreferences.hasSystemNotificationPermission();

      if (mounted) {
        setState(() {
          _goalNotificationsEnabled = goalPref;
          _hasSystemPermission = systemPerm;
        });
      }
    } catch (e) {
      print('Error loading goal notification preference: $e');
    }
  }

  /// Check system permission status (for showing warnings)
  Future<void> _checkSystemPermission() async {
    if (!mounted) return;

    try {
      final hasPermission =
          await GoalNotificationPreferences.hasSystemNotificationPermission();

      if (mounted && _hasSystemPermission != hasPermission) {
        setState(() {
          _hasSystemPermission = hasPermission;
        });

        // Show warning if system permission was revoked
        if (!hasPermission && _goalNotificationsEnabled) {
          _showSystemPermissionWarning();
        }
      }
    } catch (e) {
      print('Error checking system permission: $e');
    }
  }

  void _showSystemPermissionWarning() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'System notifications are disabled. Enable them in settings to receive goal reminders.',
        ),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () async {
            try {
              await openAppSettings();
            } catch (e) {
              print('Error opening settings: $e');
            }
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Handle goal notification toggle
  Future<void> _handleGoalNotificationToggle(bool value) async {
    if (!mounted) return;

    setState(() {
      _goalNotificationsEnabled = value;
    });

    try {
      // Save preference locally
      await GoalNotificationPreferences.setGoalNotificationEnabled(value);

      if (value) {
        // User enabled goal notifications - check system permission
        if (!_hasSystemPermission) {
          // Request system permission if not granted
          final status = await Permission.notification.request();

          if (mounted) {
            setState(() {
              _hasSystemPermission = status.isGranted;
            });

            if (status.isGranted) {
              _showSnackbar('Goal notifications enabled!');
            } else if (status.isPermanentlyDenied) {
              _showSystemPermissionDialog();
            } else {
              _showSnackbar('System permission needed for notifications');
            }
          }
        } else {
          _showSnackbar('Goal notifications enabled!');
        }
      } else {
        // User disabled goal notifications
        setState(() {
          _reminderTimes.clear(); // Clear reminders when disabled
        });
        _showSnackbar('Goal notifications disabled');
      }
    } catch (e) {
      print('Error handling goal notification toggle: $e');
      // Revert state on error
      if (mounted) {
        setState(() {
          _goalNotificationsEnabled = !value;
        });
      }
    }
  }

  void _showSystemPermissionDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('System Permission Required'),
          content: const Text(
            'To receive goal reminders, please enable notifications in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await openAppSettings();
                } catch (e) {
                  print('Error opening settings: $e');
                }
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

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
          // Initialize data only once
          if (state is StudentDataLoaded && !_isInitialized) {
            final student = state.student;
            _selectedGoalIndex = _goalOptions.indexWhere(
              (goal) => goal.title == student.goal.title,
            );
            _reminderTimes.clear();
            if (_goalNotificationsEnabled) {
              _reminderTimes.addAll(student.goal.reminder);
            }
            _isInitialized = true;
          }

          return SafeArea(
            child: Column(
              children: [
                // Header (same as before)
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
                      const SizedBox(width: 48),
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

                          // Goal selection (same as before)
                          BBText(
                            data: 'Pick a goal',
                            style: context.textStyle.titleSmall?.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Goal options (same as before)
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

                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),

                          // Goal notifications toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BBText(
                                      data: 'Goal Reminder Notifications',
                                      style: context.textStyle.titleSmall
                                          ?.copyWith(
                                            fontSize: 12,
                                            color: BBColors.primaryBlue,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    BBText(
                                      data: 'Get reminded about daily goals',
                                      style: context.textStyle.titleSmall
                                          ?.copyWith(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        BBText(
                                          data: 'eg: Remind me on X time?',
                                          style: context.textStyle.titleSmall
                                              ?.copyWith(
                                                fontSize: 12,
                                                color: BBColors.disabledText,
                                              ),
                                        ),
                                        if (!_hasSystemPermission &&
                                            _goalNotificationsEnabled) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.warning_amber,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _goalNotificationsEnabled,
                                onChanged: _handleGoalNotificationToggle,
                                activeColor: Colors.white,
                                activeTrackColor: Colors.blue,
                              ),
                            ],
                          ),

                          // System permission warning
                          if (!_hasSystemPermission &&
                              _goalNotificationsEnabled) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Enable system notifications in device settings to receive reminders.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        await openAppSettings();
                                      } catch (e) {
                                        print('Error opening settings: $e');
                                      }
                                    },
                                    child: Text(
                                      'Settings',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Add reminder button - show if goal notifications are enabled
                          if (_goalNotificationsEnabled) ...[
                            InkWell(
                              onTap: _showAddReminderDialog,
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

                            // Test notification button
                            TextButton(
                              onPressed: _testNotification,
                              child: const Text('Test Notification (10s)'),
                            ),
                          ] else ...[
                            // Disabled state
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_off,
                                    color: Colors.grey[500],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Enable goal notifications to add reminders',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Show reminders only if goal notifications are enabled
                          if (_goalNotificationsEnabled) ...[
                            ...List.generate(_reminderTimes.length, (index) {
                              final reminderTime = _reminderTimes[index];
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
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
                                          });
                                        },
                                      ),
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
                          ],

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
                        // Only save reminders if goal notifications are enabled
                        final remindersToSave =
                            _goalNotificationsEnabled
                                ? _reminderTimes
                                : <DateTime>[];

                        context.read<StudentBloc>().add(
                          StudentUpdateGoals(
                            goal: Goal(
                              value: _goalOptions[_selectedGoalIndex].quizzes,
                              status: false,
                              title: _goalOptions[_selectedGoalIndex].title,
                              description:
                                  _goalOptions[_selectedGoalIndex].description,
                              reminder: remindersToSave,
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
    if (!_goalNotificationsEnabled) {
      _showSnackbar('Please enable goal notifications first');
      return;
    }

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      DateTime now = DateTime.now();
      DateTime reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (reminderDateTime.isBefore(now)) {
        reminderDateTime = reminderDateTime.add(const Duration(days: 1));
      }

      bool isDuplicate = _reminderTimes.any(
        (existingTime) =>
            existingTime.hour == reminderDateTime.hour &&
            existingTime.minute == reminderDateTime.minute,
      );

      if (!isDuplicate) {
        setState(() {
          _reminderTimes.add(reminderDateTime);
        });
      } else {
        _showSnackbar('This reminder time already exists!');
      }
    }
  }

  Future<void> _testNotification() async {
    if (!_goalNotificationsEnabled) {
      _showSnackbar('Please enable goal notifications first');
      return;
    }

    final canSend =
        await GoalNotificationPreferences.canSendGoalNotifications();
    if (!canSend) {
      _showSnackbar(
        'Cannot send notifications. Check app and system settings.',
      );
      return;
    }

    final notificationService = BBNotificationService();
    await notificationService.initialize();

    final testTime = DateTime.now().add(const Duration(seconds: 10));
    await notificationService.scheduleGoalReminder(
      id: 999999,
      title: 'Test Goal Notification',
      body: 'This is a test notification for goal reminders',
      scheduledTime: testTime,
    );

    _showSnackbar('Test notification scheduled for 10 seconds from now');
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
