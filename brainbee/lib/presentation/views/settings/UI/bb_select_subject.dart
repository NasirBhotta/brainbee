import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/settings/bloc/setting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectSubjectsScreen extends StatefulWidget {
  final int selectedGrade;
  final StudentModel student;
  const SelectSubjectsScreen({
    super.key,
    required this.student,
    required this.selectedGrade,
  });

  @override
  State<SelectSubjectsScreen> createState() => _SelectSubjectsScreenState();
}

class _SelectSubjectsScreenState extends State<SelectSubjectsScreen> {
  List<String> selectedSubjects = [];
  bool isLoading = false;
  int? selectedGrade;

  final Map<int, List<Map<String, dynamic>>> subjectsByGrade = {
    9: [
      {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.blue},
      {'name': 'Physics', 'icon': Icons.science, 'color': Colors.purple},
      {'name': 'Chemistry', 'icon': Icons.biotech, 'color': Colors.green},
      {'name': 'Biology', 'icon': Icons.local_florist, 'color': Colors.teal},
      {'name': 'English', 'icon': Icons.book, 'color': Colors.orange},
      {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.brown},
      {'name': 'Geography', 'icon': Icons.public, 'color': Colors.indigo},
      {
        'name': 'Computer Science',
        'icon': Icons.computer,
        'color': Colors.cyan,
      },
    ],
    10: [
      {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.blue},
      {'name': 'Physics', 'icon': Icons.science, 'color': Colors.purple},
      {'name': 'Chemistry', 'icon': Icons.biotech, 'color': Colors.green},
      {'name': 'Biology', 'icon': Icons.local_florist, 'color': Colors.teal},
      {'name': 'English', 'icon': Icons.book, 'color': Colors.orange},
      {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.brown},
      {'name': 'Geography', 'icon': Icons.public, 'color': Colors.indigo},
      {
        'name': 'Computer Science',
        'icon': Icons.computer,
        'color': Colors.cyan,
      },
      {'name': 'Economics', 'icon': Icons.trending_up, 'color': Colors.red},
    ],
    11: [
      {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.blue},
      {'name': 'Physics', 'icon': Icons.science, 'color': Colors.purple},
      {'name': 'Chemistry', 'icon': Icons.biotech, 'color': Colors.green},
      {'name': 'Biology', 'icon': Icons.local_florist, 'color': Colors.teal},
      {'name': 'English', 'icon': Icons.book, 'color': Colors.orange},
      {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.brown},
      {'name': 'Geography', 'icon': Icons.public, 'color': Colors.indigo},
      {
        'name': 'Computer Science',
        'icon': Icons.computer,
        'color': Colors.cyan,
      },
      {'name': 'Economics', 'icon': Icons.trending_up, 'color': Colors.red},
      {'name': 'Psychology', 'icon': Icons.psychology, 'color': Colors.pink},
    ],
    12: [
      {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.blue},
      {'name': 'Physics', 'icon': Icons.science, 'color': Colors.purple},
      {'name': 'Chemistry', 'icon': Icons.biotech, 'color': Colors.green},
      {'name': 'Biology', 'icon': Icons.local_florist, 'color': Colors.teal},
      {'name': 'English', 'icon': Icons.book, 'color': Colors.orange},
      {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.brown},
      {'name': 'Geography', 'icon': Icons.public, 'color': Colors.indigo},
      {
        'name': 'Computer Science',
        'icon': Icons.computer,
        'color': Colors.cyan,
      },
      {'name': 'Economics', 'icon': Icons.trending_up, 'color': Colors.red},
      {'name': 'Psychology', 'icon': Icons.psychology, 'color': Colors.pink},
      {'name': 'Philosophy', 'icon': Icons.school, 'color': Colors.deepOrange},
      {'name': 'Statistics', 'icon': Icons.bar_chart, 'color': Colors.amber},
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeSelectedSubjects();
    _initializeSelectedGrade();
  }

  void _initializeSelectedSubjects() {
    // Get the latest student data from StudentBloc
    final studentState = context.read<StudentBloc>().state;
    if (studentState is StudentDataLoaded) {
      selectedSubjects = List.from(studentState.student.subjects);
    } else if (widget.student.subjects.isNotEmpty) {
      selectedSubjects = List.from(widget.student.subjects);
    }
  }

  void _initializeSelectedGrade() {
    // Get grade from settings state safely
    final settingsState = context.read<SettingsBloc>().state;
    final localGrade = _getGradeFromState(settingsState);

    selectedGrade = localGrade ?? widget.selectedGrade;
  }

  int? _getGradeFromState(SettingsState state) {
    if (state is SettingsGradeLoadedLocally) {
      return state.grade;
    } else if (state is SettingsGradeSavedLocal) {
      return state.grade;
    }
    return null;
  }

  // Helper method to compare two lists
  bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!a.contains(b[i])) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final subjects = subjectsByGrade[widget.selectedGrade] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Select Subjects', style: context.textStyle.titleMedium),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SettingsBloc, SettingsState>(
            listener: (context, state) {
              setState(() {
                if (state is SettingsLoading) {
                  isLoading = true;
                } else if (state is SettingsUpdateSuccess) {
                  isLoading = false;
                  // Refresh student data after successful update
                  context.read<StudentBloc>().add(StudentFetchData());

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subjects updated successfully!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // Navigate back after a short delay
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  });
                } else if (state is SettingsUpdateFailure) {
                  isLoading = false;

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating subjects: ${state.error}'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  isLoading = false;
                }
              });
            },
          ),
          BlocListener<StudentBloc, StudentState>(
            listener: (context, state) {
              if (state is StudentDataLoaded) {
                // Only update if this is a fresh load and subjects have changed
                if (!_listsEqual(selectedSubjects, state.student.subjects)) {
                  setState(() {
                    selectedSubjects = List.from(state.student.subjects);
                  });
                }
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildSectionHeader('Academic Preferences'),
              const SizedBox(height: 16),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BBColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: BBColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grade ${selectedGrade ?? widget.selectedGrade}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selectedSubjects.length} subjects selected',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Subjects Section
              _buildSectionHeader('Available Subjects'),
              const SizedBox(height: 16),

              // Subjects Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final isSelected = selectedSubjects.contains(subject['name']);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedSubjects.remove(subject['name']);
                        } else {
                          selectedSubjects.add(subject['name']);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? BBColors.primaryColor
                                  : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: BBColors.primaryColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          else
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: subject['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    subject['icon'],
                                    size: 32,
                                    color: subject['color'],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    subject['name'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? Colors.black87
                                              : Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: BBColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Helper Text
              if (selectedSubjects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please select at least one subject to continue',
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // Save Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient:
                      selectedSubjects.isNotEmpty && !isLoading
                          ? const LinearGradient(
                            colors: [
                              BBColors.primaryColor,
                              BBColors.secondaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                  color:
                      selectedSubjects.isEmpty || isLoading
                          ? Colors.grey[300]
                          : null,
                ),
                child: ElevatedButton(
                  onPressed:
                      selectedSubjects.isNotEmpty && !isLoading
                          ? () {
                            context.read<SettingsBloc>().add(
                              SettingsUpdateGradeAndSubjects(
                                grade: selectedGrade!,
                                subjects: selectedSubjects,
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      isLoading
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
                          : Text(
                            'Save Selection',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  selectedSubjects.isNotEmpty
                                      ? BBColors.white
                                      : Colors.grey[600],
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.blue[600],
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
