// 2. Select Subjects Screen
import 'package:brainbee/core/constants/bb_colors.dart';
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
  };

  @override
  void initState() {
    super.initState();
    _initializeSelectedSubjects();
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
      backgroundColor: const Color(0xFF4DB6AC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Subjects',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                      duration: Duration(seconds: 2),
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
                      duration: const Duration(seconds: 3),
                    ),
                  );
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose subjects for ${widget.selectedGrade}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${selectedSubjects.length} subjects selected',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final isSelected = selectedSubjects.contains(
                      subject['name'],
                    );

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
                          color:
                              isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          border:
                              isSelected
                                  ? Border.all(
                                    color: const Color(0xFF4DB6AC),
                                    width: 3,
                                  )
                                  : null,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: subject['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                subject['icon'],
                                size: 35,
                                color: subject['color'],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              subject['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF4DB6AC),
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      selectedSubjects.isNotEmpty && !isLoading
                          ? () {
                            context.read<SettingsBloc>().add(
                              SettingsUpdateGradeAndSubjects(
                                grade: widget.selectedGrade,
                                subjects: selectedSubjects,
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4DB6AC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            color: BBColors.secondaryColor,
                          )
                          : const Text(
                            'Save Selection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to compare two lists
}
