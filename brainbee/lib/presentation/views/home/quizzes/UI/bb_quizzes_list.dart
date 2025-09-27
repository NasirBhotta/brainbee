import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/home/quizzes/UI/bb_quiz_screen.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/book_model.dart';
import 'package:flutter/material.dart';

class BbQuizzesListScreen extends StatefulWidget {
  final Topic topic;
  const BbQuizzesListScreen({super.key, required this.topic});

  @override
  State<BbQuizzesListScreen> createState() => _BbQuizzesListScreenState();
}

class _BbQuizzesListScreenState extends State<BbQuizzesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BBColors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: BBColors.black),
        ),
        title: BBText(
          data: widget.topic.topic,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: BBColors.black,
          ),
        ),
      ),

      body: ListView.separated(
        itemBuilder: (context, index) {
          return ListTile(
            title: BBText(data: "${widget.topic.topic} Quiz ${index + 1}"),
            subtitle: Text('Click to start the quiz'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BBInAppQuizScreen(
                        quizId: widget.topic.quizzes[index].id,
                      ),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) {
          return Divider(color: BBColors.borderGray, height: 0.5);
        },
        itemCount: widget.topic.quizzes.length,
      ),
    );
  }
}
