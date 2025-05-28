import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';

class BbViewChapter extends StatefulWidget {
  final String bookTitle;
  final String chapterTitle;
  final String chapterText;

  const BbViewChapter({
    super.key,
    required this.bookTitle,
    required this.chapterTitle,
    required this.chapterText,
  });

  @override
  State<BbViewChapter> createState() => _BbViewChapterState();
}

class _BbViewChapterState extends State<BbViewChapter> {
  String selectedText = '';
  bool showOptions = false;
  OverlayEntry? overlayEntry;

  void _handleTextSelection(String text) {
    setState(() {
      selectedText = text.trim();
      showOptions = selectedText.isNotEmpty;
    });
  }

  void _hideOptions() {
    setState(() {
      showOptions = false;
      selectedText = '';
    });
  }

  void _handleSummarization() {
    if (selectedText.isNotEmpty) {
      // Navigate to summarization screen or show dialog
      _showActionDialog(
        'Summarization',
        'Generating summary for the selected text...',
      );
    }
  }

  void _handleExplanation() {
    if (selectedText.isNotEmpty) {
      // Navigate to explanation screen or show dialog
      _showActionDialog(
        'Explanation',
        'Generating explanation for the selected text...',
      );
    }
  }

  void _handleChatWithAI() {
    if (selectedText.isNotEmpty) {
      // Navigate to chat screen with selected text
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChatWithAIScreen(
                bookTitle: widget.bookTitle,
                chapterTitle: widget.chapterTitle,
                selectedText: selectedText,
              ),
        ),
      );
    }
  }

  void _showActionDialog(String action, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(action),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selected Text:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedText,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bookTitle,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.chapterTitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: _hideOptions,
        child: Stack(
          children: [
            // Main content
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: BBColors.primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.menu_book, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reading Mode',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Select text to interact',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Book content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: SelectableText(
                        widget.chapterText,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                        onSelectionChanged: (selection, cause) {
                          final text = widget.chapterText.substring(
                            selection.start,
                            selection.end,
                          );
                          _handleTextSelection(text);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Floating action options
            if (showOptions)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Selected Text Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: BBColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.summarize,
                            label: 'Summarize',
                            onTap: _handleSummarization,
                          ),
                          _buildActionButton(
                            icon: Icons.lightbulb_outline,
                            label: 'Explain',
                            onTap: _handleExplanation,
                          ),
                          _buildActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: 'Chat AI',
                            onTap: _handleChatWithAI,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: BBColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat with AI Screen (placeholder implementation)
class ChatWithAIScreen extends StatefulWidget {
  final String bookTitle;
  final String chapterTitle;
  final String selectedText;

  const ChatWithAIScreen({
    super.key,
    required this.bookTitle,
    required this.chapterTitle,
    required this.selectedText,
  });

  @override
  State<ChatWithAIScreen> createState() => _ChatWithAIScreenState();
}

class _ChatWithAIScreenState extends State<ChatWithAIScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add initial message with selected text
    _messages.add({
      'isUser': false,
      'message':
          'I can help you understand this text: "${widget.selectedText}"\n\nWhat would you like to know about it?',
      'timestamp': DateTime.now(),
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'isUser': true,
          'message': _messageController.text.trim(),
          'timestamp': DateTime.now(),
        });

        // Simulate AI response
        _messages.add({
          'isUser': false,
          'message':
              'This is a simulated AI response to your question about the selected text.',
          'timestamp': DateTime.now(),
        });
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat with AI',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Selected text context
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Context from ${widget.chapterTitle}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: BBColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.selectedText,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Chat messages
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(
                    message['message'],
                    message['isUser'],
                  );
                },
              ),
            ),
          ),
          // Message input
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask about the selected text...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: BBColors.primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? BBColors.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

// Example usage:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => BookReadingScreen(
//       bookTitle: "Selected Book Title",
//       chapterTitle: "Chapter 1: Introduction",
//       chapterText: "Your long chapter text content goes here...",
//     ),
//   ),
// );
