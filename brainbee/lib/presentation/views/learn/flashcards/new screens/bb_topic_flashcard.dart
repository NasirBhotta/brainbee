import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/learn/flashcards/new%20screens/bb_flashcard_new.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/flashcard_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BbTopicFlashcardsListScreen extends StatelessWidget {
  final String topicTitle;
  final List<Flashcard> flashcards;

  const BbTopicFlashcardsListScreen({
    super.key,
    required this.topicTitle,
    required this.flashcards,
  });

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final cardDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (cardDate == today) {
      return 'Today at ${DateFormat('h:mm a').format(dateTime)}';
    } else if (cardDate == yesterday) {
      return 'Yesterday at ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, y • h:mm a').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the creation time from the first flashcard
    // Assuming all flashcards in this list were created at the same time
    final createdAt =
        flashcards.isNotEmpty ? flashcards.first.generatedAt : DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: BBText(data: topicTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: BBColors.primaryColor, height: 4.0),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body:
          flashcards.isEmpty
              ? const Center(child: Text('No flashcards found'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: BBColors.primaryColor.withOpacity(0.1),
                      foregroundColor: BBColors.primaryColor,
                      child: Icon(Icons.style, size: 24),
                    ),
                    title: Text(
                      '${flashcards.length} Flashcards',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      _formatDateTime(createdAt),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BBFlashCardsScreenNew(
                                flashcards: flashcards,
                                initialIndex: 0,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
    );
  }
}
