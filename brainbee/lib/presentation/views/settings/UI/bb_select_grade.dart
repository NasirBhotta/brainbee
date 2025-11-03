import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/settings/bloc/setting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectYearGradeScreen extends StatefulWidget {
  final StudentModel student;
  const SelectYearGradeScreen({super.key, required this.student});

  @override
  State<SelectYearGradeScreen> createState() => _SelectYearGradeScreenState();
}

class _SelectYearGradeScreenState extends State<SelectYearGradeScreen> {
  int? selectedGrade;
  bool isLoading = false;
  final List<Map<String, dynamic>> grades = [
    {
      'grade': 9,
      'subjects': 8,
      'icon': Icons.looks_one,
      'color': const Color(0xFF2196F3),
      'description': 'Foundation Year',
    },
    {
      'grade': 10,
      'subjects': 9,
      'icon': Icons.looks_two,
      'color': const Color(0xFF4CAF50),
      'description': 'Intermediate Year',
    },
    {
      'grade': 11,
      'subjects': 10,
      'icon': Icons.looks_3,
      'color': const Color(0xFFFF9800),
      'description': 'Pre-Advanced Year',
    },
    {
      'grade': 12,
      'subjects': 12,
      'icon': Icons.looks_4,
      'color': const Color(0xFF9C27B0),
      'description': 'Advanced Year',
    },
  ];

  @override
  void initState() {
    super.initState();
    print("working");
    context.read<SettingsBloc>().add(SettingsLoadGradeFromLocal());
  }

  int? _getGradeFromState(SettingsState state) {
    if (state is SettingsGradeLoadedLocally) {
      return state.grade;
    } else if (state is SettingsGradeSavedLocal) {
      return state.grade;
    }
    return null;
  }

  void _setInitialGrade(SettingsState state) {
    final localGrade = _getGradeFromState(state);

    // Priority: Use student grade if it's valid and matches local storage,
    // otherwise use local storage grade, otherwise no selection

    if (widget.student.grade >= 9 &&
        widget.student.grade <= 12 &&
        widget.student.grade != 0 &&
        localGrade == widget.student.grade) {
      selectedGrade = widget.student.grade;
    } else if (localGrade != null && localGrade >= 9 && localGrade <= 12) {
      selectedGrade = localGrade;
    } else {
      selectedGrade = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Select Year Grade', style: context.textStyle.titleMedium),
        centerTitle: true,
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          setState(() {
            if (state is SettingsLoading) {
              isLoading = true;
            } else {
              isLoading = false;

              // Set initial grade when grade is loaded from local storage
              if (state is SettingsGradeLoadedLocally) {
                print("the state is ${state.grade}");
                _setInitialGrade(state);
              }

              // Handle successful grade save
              if (state is SettingsGradeSavedLocal) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Grade ${state.grade} saved successfully!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Navigate back after successful save
                Navigator.pop(context);
              }

              // Handle errors
              if (state is SettingsUpdateFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Header Section
              _buildSectionHeader('Academic Year'),
              const SizedBox(height: 16),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select your current academic year to access relevant content',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Grades Section
              _buildSectionHeader('Available Grades'),
              const SizedBox(height: 16),

              // Grades List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: grades.length,
                itemBuilder: (context, index) {
                  final grade = grades[index];
                  final isSelected = selectedGrade == grade['grade'];
                  print(
                    "selected grade: $selectedGrade, current grade: ${grade['grade']}, isSelected: $isSelected",
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGrade = grade['grade'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (grade['color'] as Color).withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                grade['icon'] as IconData,
                                color: grade['color'] as Color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Grade ${grade['grade']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? Colors.black87
                                              : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    grade['description'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.book_outlined,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${grade['subjects']} Subjects',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: BBColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.circle_outlined,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Helper Text
              if (selectedGrade == null)
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
                          'Please select a grade to continue',
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

              // Continue Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient:
                      selectedGrade != null && !isLoading
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
                      selectedGrade == null || isLoading
                          ? Colors.grey[300]
                          : null,
                ),
                child: ElevatedButton(
                  onPressed:
                      selectedGrade != null && !isLoading
                          ? () {
                            context.read<SettingsBloc>().add(
                              SettingsSaveGradeLocal(selectedGrade!),
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
                            'Continue',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  selectedGrade != null
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
