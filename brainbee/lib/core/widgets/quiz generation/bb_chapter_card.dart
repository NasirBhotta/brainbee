// import 'package:brainbee/presentation/views/home/quizzes/models/book_model.dart';
// import 'package:flutter/material.dart';
// import 'package:brainbee/core/constants/bb_colors.dart';

// class BbChapterCard extends StatelessWidget {
//   final String chapterTitle;
//   final String subtitle;
//   final List<BbChapterItem> items;
//   final void Function(BbChapterItem item)? onItemTap;

//   const BbChapterCard({
//     super.key,
//     required this.chapterTitle,
//     required this.subtitle,
//     required this.items,
//     this.onItemTap,
//   });

//   factory BbChapterCard.fromChapter({
//     required Chapter chapter,
//     required void Function(Topic topic) onTopicTap,
//   }) {
//     return BbChapterCard(
//       chapterTitle: "Chapter No ${chapter.chapter}",
//       subtitle: "Read More...",
//       items:
//           chapter.topics
//               .map<BbChapterItem>((topic) => BbChapterItem.fromTopic(topic))
//               .toList(),
//       onItemTap: (item) {
//         final topic = item.data as Topic;
//         onTopicTap(topic);
//       },
//     );
//   }

//   factory BbChapterCard.fromJsonChapter({
//     required Map<String, dynamic> chapter,
//     required void Function(Map<String, dynamic> section)? onSectionTap,
//   }) {
//     final chapterNumber = chapter['chapter_number']?.toString() ?? '0';
//     final chapterTitle = chapter['chapter_title'] ?? 'Unknown Chapter';
//     final sections = chapter['sections'] as List<dynamic>? ?? [];

//     return BbChapterCard(
//       chapterTitle: 'Chapter $chapterNumber',
//       subtitle: chapterTitle,
//       items:
//           sections
//               .map<BbChapterItem>(
//                 (section) =>
//                     BbChapterItem.fromSection(section as Map<String, dynamic>),
//               )
//               .toList(),
//       onItemTap:
//           onSectionTap != null
//               ? (item) {
//                 final section = item.data as Map<String, dynamic>;
//                 onSectionTap(section);
//               }
//               : null,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Container(
//         decoration: BoxDecoration(
//           color: BBColors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: ExpansionTile(
//             shape: const Border(),
//             tilePadding: const EdgeInsets.all(16),
//             childrenPadding: EdgeInsets.zero,
//             backgroundColor: BBColors.white,
//             collapsedBackgroundColor: BBColors.white,
//             title: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         chapterTitle,
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         subtitle,
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             trailing: const Icon(Icons.keyboard_arrow_down),
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(12),
//                     bottomRight: Radius.circular(12),
//                   ),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Column(
//                   children:
//                       items.map((item) {
//                         final data = item.data;

//                         // ✅ Extract lock/unlock status and progress
//                         final bool isUnlocked = _getIsUnlocked(data);
//                         final int quizzesCompleted = _getQuizzesCompleted(data);
//                         final int totalQuizzes = _getTotalQuizzes(data);
//                         final int remaining = _getRemainingToUnlock(data);

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 4,
//                           ),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 4,
//                               ),

//                               // ✅ Show lock/unlock icon
//                               leading: Icon(
//                                 isUnlocked
//                                     ? Icons.check_circle_outline
//                                     : Icons.lock_outline,
//                                 color: isUnlocked ? Colors.green : Colors.grey,
//                                 size: 24,
//                               ),

//                               // ✅ Title with lock status styling
//                               title: Text(
//                                 item.title,
//                                 style: Theme.of(
//                                   context,
//                                 ).textTheme.bodyMedium?.copyWith(
//                                   fontWeight: FontWeight.w500,
//                                   color:
//                                       isUnlocked ? Colors.black : Colors.grey,
//                                 ),
//                               ),

//                               // ✅ Subtitle showing progress or lock message
//                               subtitle:
//                                   isUnlocked
//                                       ? Text(
//                                         "$quizzesCompleted / $totalQuizzes quizzes completed",
//                                         style: TextStyle(
//                                           color: Colors.grey.shade700,
//                                           fontSize: 12,
//                                         ),
//                                       )
//                                       : Text(
//                                         "🔒 Locked - Complete $remaining more quiz(es) to unlock",
//                                         style: TextStyle(
//                                           color: Colors.red.shade400,
//                                           fontSize: 12,
//                                         ),
//                                       ),

//                               // ✅ Trailing chip for remaining quizzes
//                               trailing:
//                                   isUnlocked && remaining > 0
//                                       ? Chip(
//                                         label: Text(
//                                           "$remaining more",
//                                           style: const TextStyle(
//                                             fontSize: 10,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         backgroundColor: Colors.orange.shade100,
//                                         padding: EdgeInsets.zero,
//                                         visualDensity: VisualDensity.compact,
//                                       )
//                                       : isUnlocked
//                                       ? Icon(
//                                         Icons.arrow_forward_ios,
//                                         size: 14,
//                                         color: Colors.grey.shade400,
//                                       )
//                                       : null,

//                               // ✅ Only allow tap if unlocked
//                               enabled: isUnlocked,
//                               onTap:
//                                   isUnlocked && onItemTap != null
//                                       ? () => onItemTap!(item)
//                                       : null,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ✅ Helper methods for safe data extraction
//   bool _getIsUnlocked(dynamic data) {
//     if (data is Topic) {
//       return data.isUnlocked;
//     } else if (data is Map) {
//       print("The Map Data is ${data['isUnlocked']}");
//       return data['isUnlocked'] as bool? ?? false;
//     }
//     return false;
//   }

//   int _getQuizzesCompleted(dynamic data) {
//     if (data is Topic) {
//       return data.quizzesCompleted;
//     } else if (data is Map) {
//       return data['quizzesCompleted'] as int? ?? 0;
//     }
//     return 0;
//   }

//   int _getTotalQuizzes(dynamic data) {
//     if (data is Topic) {
//       return data.totalQuizzes;
//     } else if (data is Map) {
//       return data['totalQuizzes'] as int? ?? 0;
//     }
//     return 0;
//   }

//   int _getRemainingToUnlock(dynamic data) {
//     if (data is Topic) {
//       return data.remainingToUnlock;
//     } else if (data is Map) {
//       return data['remainingToUnlock'] as int? ?? 0;
//     }
//     return 0;
//   }
// }

// class BbChapterItem {
//   final String title;
//   final Widget? icon;
//   final Color? iconBackgroundColor;
//   final dynamic data;

//   const BbChapterItem({
//     required this.title,
//     this.icon,
//     this.iconBackgroundColor,
//     this.data,
//   });

//   factory BbChapterItem.fromTopic(Topic topic) {
//     return BbChapterItem(
//       title: topic.topic,
//       icon: Icon(Icons.topic_outlined, color: BBColors.primaryColor, size: 18),
//       iconBackgroundColor: BBColors.primaryColor.withOpacity(0.1),
//       data: topic,
//     );
//   }

//   factory BbChapterItem.fromSection(Map<String, dynamic> section) {
//     return BbChapterItem(
//       title: section['section_title'] ?? 'Unknown Section',
//       icon: Icon(
//         Icons.menu_book_rounded,
//         color: BBColors.primaryColor,
//         size: 18,
//       ),
//       iconBackgroundColor: BBColors.primaryColor.withOpacity(0.1),
//       data: section,
//     );
//   }
// }

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

  factory BbChapterCard.fromChapter({
    required Chapter chapter, // Your existing Chapter model
    required void Function(Topic topic) onTopicTap,
  }) {
    return BbChapterCard(
      chapterTitle: "Chapter No ${chapter.chapter}",
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: BBColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ExpansionTile(
            shape: const Border(),
            tilePadding: const EdgeInsets.all(16),
            childrenPadding: EdgeInsets.zero,
            backgroundColor: BBColors.white,
            collapsedBackgroundColor: BBColors.white,
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapterTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.keyboard_arrow_down),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children:
                      items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    item.iconBackgroundColor ??
                                    BBColors.primaryColor.withOpacity(0.1),
                                child:
                                    item.icon ??
                                    Icon(
                                      Icons.topic_outlined,
                                      color: BBColors.primaryColor,
                                      size: 18,
                                    ),
                              ),
                              title: Text(
                                item.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey.shade400,
                              ),
                              onTap:
                                  onItemTap != null
                                      ? () => onItemTap!(item)
                                      : null,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
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
      icon: Icon(Icons.topic_outlined, color: BBColors.primaryColor, size: 18),
      iconBackgroundColor: BBColors.primaryColor.withOpacity(0.1),
      data: topic,
    );
  }

  // Factory constructor for sections
  factory BbChapterItem.fromSection(Map<String, dynamic> section) {
    return BbChapterItem(
      title: section['section_title'] ?? 'Unknown Section',
      icon: Icon(
        Icons.menu_book_rounded,
        color: BBColors.primaryColor,
        size: 18,
      ),
      iconBackgroundColor: BBColors.primaryColor.withOpacity(0.1),
      data: section,
    );
  }
}
