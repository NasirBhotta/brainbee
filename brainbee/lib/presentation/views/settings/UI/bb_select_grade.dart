import 'package:flutter/material.dart';

// 1. Select Year Grade Screen
class SelectYearGradeScreen extends StatefulWidget {
  const SelectYearGradeScreen({super.key});

  @override
  State<SelectYearGradeScreen> createState() => _SelectYearGradeScreenState();
}

class _SelectYearGradeScreenState extends State<SelectYearGradeScreen> {
  String? selectedGrade;

  final List<Map<String, dynamic>> grades = [
    {'grade': '9th Grade', 'subjects': 8, 'icon': Icons.looks_one},
    {'grade': '10th Grade', 'subjects': 9, 'icon': Icons.looks_two},
    {'grade': '11th Grade', 'subjects': 10, 'icon': Icons.looks_3},
    {'grade': '12th Grade', 'subjects': 12, 'icon': Icons.looks_4},
  ];

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
      body: Padding(
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
                                    grade['grade'],
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
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder:
                          //         (context) => SelectSubjectsScreen(
                          //           selectedGrade: selectedGrade!,
                          //         ),
                          //   ),
                          // );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4DB6AC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
