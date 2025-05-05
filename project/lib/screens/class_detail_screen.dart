import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../widgets/class_materials_tab.dart';
import '../widgets/class_discussions_tab.dart';
import '../widgets/class_grades_tab.dart';
import '../widgets/class_assignments_tab.dart';
import '../widgets/class_quizzes_tab.dart';

class ClassDetailScreen extends StatelessWidget {
  final ClassModel classData;

  const ClassDetailScreen({super.key, required this.classData});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(classData.name),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Materials'),
              Tab(text: 'Discussions'),
              Tab(text: 'Grades'),
              Tab(text: 'Assignments'),
              Tab(text: 'Quizzes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ClassMaterialsTab(classId: classData.id),
            ClassDiscussionsTab(classId: classData.id),
            ClassGradesTab(classId: classData.id),
            ClassAssignmentsTab(classId: classData.id),
            ClassQuizzesTab(classId: classData.id),
          ],
        ),
      ),
    );
  }
}