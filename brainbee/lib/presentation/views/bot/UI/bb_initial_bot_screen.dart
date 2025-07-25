import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/widgets/AI/bb_chat_widget.dart';
import 'package:flutter/material.dart';

enum ChatType { newChat, historyChat }

class BbInitialBotScreen extends StatefulWidget {
  const BbInitialBotScreen({super.key});

  @override
  State<BbInitialBotScreen> createState() => _BbInitialBotScreenState();
}

class _BbInitialBotScreenState extends State<BbInitialBotScreen> {
  // Sample chat history data
  final List<ChatHistoryItem> chatHistory = [
    ChatHistoryItem(
      title: "General Inquiry Greeting",
      date: DateTime(2024, 10, 15),
    ),
    ChatHistoryItem(
      title: "General Inquiry: Hello",
      date: DateTime(2024, 10, 14),
    ),
    ChatHistoryItem(
      title: "How to solve quadratic equations?",
      date: DateTime(2024, 10, 13),
    ),
    ChatHistoryItem(
      title: "Explain photosynthesis process",
      date: DateTime(2024, 10, 12),
    ),
    ChatHistoryItem(
      title: "Grammar: Past vs Present tense",
      date: DateTime(2024, 10, 11),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text('Ai Tutor', style: context.textStyle.titleMedium),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // AskBot Section
          // Container(
          //   width: double.infinity,
          //   margin: const EdgeInsets.all(16),
          //   padding: const EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(20),
          //     color: BBColors.successGreen,
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             const Text(
          //               'Ask PBot',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 28,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             const SizedBox(height: 8),
          //             Text(
          //               'Get instant help with your questions',
          //               style: TextStyle(
          //                 color: Colors.white.withOpacity(0.9),
          //                 fontSize: 14,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Container(
          //         width: 80,
          //         height: 80,
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.2),
          //           shape: BoxShape.circle,
          //         ),
          //         child: Stack(
          //           children: [
          //             Center(
          //               child: Container(
          //                 width: 50,
          //                 height: 50,
          //                 decoration: const BoxDecoration(
          //                   color: Colors.white,
          //                   shape: BoxShape.circle,
          //                 ),
          //                 child: const Center(
          //                   child: Icon(
          //                     Icons.smart_toy_rounded,
          //                     color: Colors.green,
          //                     size: 30,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //             Positioned(
          //               top: 15,
          //               left: 20,
          //               child: Container(
          //                 width: 8,
          //                 height: 8,
          //                 decoration: const BoxDecoration(
          //                   color: Colors.black,
          //                   shape: BoxShape.circle,
          //                 ),
          //               ),
          //             ),
          //             Positioned(
          //               top: 15,
          //               right: 20,
          //               child: Container(
          //                 width: 8,
          //                 height: 8,
          //                 decoration: const BoxDecoration(
          //                   color: Colors.black,
          //                   shape: BoxShape.circle,
          //                 ),
          //               ),
          //             ),
          //             Positioned(
          //               bottom: 20,
          //               left: 25,
          //               right: 25,
          //               child: Container(
          //                 height: 3,
          //                 decoration: BoxDecoration(
          //                   color: Colors.red,
          //                   borderRadius: BorderRadius.circular(2),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Start New Chat Button
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),

            child: ElevatedButton(
              onPressed: _startNewChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Start new chat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // History Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // History Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'October 2024',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // History List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: chatHistory.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(chatHistory[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ChatHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: Colors.blue[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(item.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onSelected: (value) => _handleMenuAction(value, item),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'continue',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, size: 20),
                        SizedBox(width: 8),
                        Text('Continue Chat'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _startNewChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BbChatWidget(chatType: ChatType.newChat),
      ),
    );
  }

  void _handleMenuAction(String action, ChatHistoryItem item) {
    switch (action) {
      case 'continue':
        // Handle continue chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => const BbChatWidget(chatType: ChatType.historyChat),
          ),
        );
        break;
      case 'rename':
        _showRenameDialog(item);
        break;
      case 'delete':
        _showDeleteDialog(item);
        break;
    }
  }

  void _showRenameDialog(ChatHistoryItem item) {
    final TextEditingController controller = TextEditingController(
      text: item.title,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename Chat'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter new name',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    item.title = controller.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(ChatHistoryItem item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: const Text(
              'Are you sure you want to delete this chat? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    chatHistory.remove(item);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class ChatHistoryItem {
  String title;
  final DateTime date;

  ChatHistoryItem({required this.title, required this.date});
}
