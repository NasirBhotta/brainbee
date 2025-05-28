// 2. Select Subjects Screen
import 'package:flutter/material.dart';

class SelectSubjectsScreen extends StatefulWidget {
  final String selectedGrade;

  const SelectSubjectsScreen({super.key, required this.selectedGrade});

  @override
  State<SelectSubjectsScreen> createState() => _SelectSubjectsScreenState();
}

class _SelectSubjectsScreenState extends State<SelectSubjectsScreen> {
  List<String> selectedSubjects = [];

  final Map<String, List<Map<String, dynamic>>> subjectsByGrade = {
    '9th Grade': [
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
    '10th Grade': [
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
    // Add more grades as needed
  };

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
      body: Padding(
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
                    selectedSubjects.isNotEmpty
                        ? () {
                          // Navigate to main app or save preferences
                          _showSuccessDialog();
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
                  'Save Selection',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF4DB6AC), size: 30),
              SizedBox(width: 10),
              Text('Success!'),
            ],
          ),
          content: const Text(
            'Your grade and subjects have been saved successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF4DB6AC)),
              ),
            ),
          ],
        );
      },
    );
  }
}
