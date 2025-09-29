import 'package:brainbee/presentation/views/home/quizzes/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';

class BbChapterCard extends StatelessWidget {
  final String chapterTitle;
  final String subtitle;
  final List<BbChapterItem> items;
  final void Function(BbChapterItem item)? onItemTap;

  const BbChapterCard({
    super.key,
    required this.chapterTitle,
    required this.subtitle,
    required this.items,
    this.onItemTap,
  });

  // Factory constructor to maintain compatibility with existing Chapter model
  factory BbChapterCard.fromChapter({
    required dynamic chapter, // Your existing Chapter model
    required void Function(Topic topic) onTopicTap,
  }) {
    return BbChapterCard(
      chapterTitle: chapter.chapter.toString(),
      subtitle: "Read More...",
      items:
          chapter.topics
              .map<BbChapterItem>((topic) => BbChapterItem.fromTopic(topic))
              .toList(),
      onItemTap: (item) {
        final topic = item.data;
        onTopicTap(topic);
      },
    );
  }

  // Factory constructor for JSON-based chapters (sections)
  factory BbChapterCard.fromJsonChapter({
    required Map<String, dynamic> chapter,
    required void Function(Map<String, dynamic> section)? onSectionTap,
  }) {
    final chapterNumber = chapter['chapter_number']?.toString() ?? '0';
    final chapterTitle = chapter['chapter_title'] ?? 'Unknown Chapter';
    final sections = chapter['sections'] as List<dynamic>? ?? [];

    return BbChapterCard(
      chapterTitle: 'Chapter $chapterNumber',
      subtitle: chapterTitle,
      items:
          sections
              .map<BbChapterItem>(
                (section) =>
                    BbChapterItem.fromSection(section as Map<String, dynamic>),
              )
              .toList(),
      onItemTap:
          onSectionTap != null
              ? (item) {
                final section = item.data as Map<String, dynamic>;
                onSectionTap(section);
              }
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const Border(top: BorderSide.none, bottom: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BBColors.primaryColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.book,
            color: BBColors.secondaryColor.withValues(alpha: 1),
            size: 24,
          ),
        ),
        title: Text(
          chapterTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: BBColors.secondaryColor),
        ),
        children:
            items.map((item) {
              return ListTile(
                style: ListTileStyle.drawer,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: item.iconBackgroundColor ?? Colors.grey,
                  child:
                      item.icon ??
                      const Text(
                        "?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
                title: Text(item.title),
                onTap: onItemTap != null ? () => onItemTap!(item) : null,
              );
            }).toList(),
      ),
    );
  }
}

// Generic item class that can represent both topics and sections
class BbChapterItem {
  final String title;
  final Widget? icon;
  final Color? iconBackgroundColor;
  final dynamic data; // Store original data (Topic, Section, or any other type)

  const BbChapterItem({
    required this.title,
    this.icon,
    this.iconBackgroundColor,
    this.data,
  });

  // Factory constructor for topics
  factory BbChapterItem.fromTopic(dynamic topic) {
    return BbChapterItem(
      title: topic.topic, // Assuming topic has a 'topic' property
      icon: const Text(
        "?",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconBackgroundColor: Colors.grey,
      data: topic,
    );
  }

  // Factory constructor for sections
  factory BbChapterItem.fromSection(Map<String, dynamic> section) {
    return BbChapterItem(
      title: section['section_title'] ?? 'Unknown Section',
      icon: const Text("📖", style: TextStyle(fontSize: 12)),
      iconBackgroundColor: Colors.grey,
      data: section,
    );
  }
}
