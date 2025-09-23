import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/settings/bloc/setting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Select Year Grade Screen
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
    {'grade': 9, 'subjects': 8, 'icon': Icons.looks_one},
    {'grade': 10, 'subjects': 9, 'icon': Icons.looks_two},
    {'grade': 11, 'subjects': 10, 'icon': Icons.looks_3},
    {'grade': 12, 'subjects': 12, 'icon': Icons.looks_4},
  ];

  @override
  void initState() {
    super.initState();

    if (widget.student.grade >= 9 &&
        widget.student.grade <= 12 &&
        widget.student.grade != 0) {
      selectedGrade = widget.student.grade;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Select Year Grade',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          setState(() {
            if (state is SettingsLoading) {
              isLoading = true;
            } else {
              isLoading = false;
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Choose your academic year',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: grades.length,
                  itemBuilder: (context, index) {
                    final grade = grades[index];
                    final isSelected = selectedGrade == grade['grade'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGrade = grade['grade'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
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
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4DB6AC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  grade['icon'],
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      grade['grade'].toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${grade['subjects']} Subjects Available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF4DB6AC),
                                  size: 30,
                                ),
                            ],
                          ),
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
                      selectedGrade != null
                          ? () {
                            context.read<SettingsBloc>().add(
                              SettingsSaveGradeLocal(selectedGrade!),
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
                            'Continue',
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
}
