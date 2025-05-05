import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/class_service.dart';
import '../models/class_model.dart';
import '../widgets/class_card.dart';
import '../widgets/loading_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile screen
            },
          ),
        ],
      ),
      body: Consumer<ClassService>(
        builder: (context, classService, child) {
          if (classService.isLoading) {
            return const LoadingIndicator();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mockClasses.length, // Replace with actual data
            itemBuilder: (context, index) {
              final classData = mockClasses[index];
              return ClassCard(
                classData: classData,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailScreen(classData: classData),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}