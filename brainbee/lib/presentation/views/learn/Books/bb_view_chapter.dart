import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/content.model.dart';
import 'package:flutter/material.dart';

class BbViewChapter extends StatefulWidget {
  final BookChapter chapter;

  const BbViewChapter({super.key, required this.chapter});

  @override
  State<BbViewChapter> createState() => _BbViewChapterState();
}

class _BbViewChapterState extends State<BbViewChapter> {
  String selectedText = '';
  bool showOptions = false;
  bool isLoading = false;
  String? errorMessage;

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
      _showActionDialog(
        'Summarization',
        'Generating summary for the selected text...',
      );
    }
  }

  void _handleExplanation() {
    if (selectedText.isNotEmpty) {
      _showActionDialog(
        'Explanation',
        'Generating explanation for the selected text...',
      );
    }
  }

  void _handleChatWithAI() {
    if (selectedText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChatWithAIScreen(
                bookTitle: widget.chapter.bookTitle,
                chapterTitle: widget.chapter.chapterTitle,
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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              widget.chapter.bookTitle,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SelectableText(
              'Chapter ${widget.chapter.chapterNumber}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: _hideOptions,
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter Title
                  SelectableText(
                    widget.chapter.chapterTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    onSelectionChanged: (selection, cause) {
                      if (selection.start != selection.end) {
                        final text = widget.chapter.chapterTitle.substring(
                          selection.start,
                          selection.end,
                        );
                        _handleTextSelection(text);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Chapter Introduction
                  if (widget.chapter.chapterIntro.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BBColors.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: BBColors.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: SelectableText(
                        widget.chapter.chapterIntro,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.grey[800],
                          fontStyle: FontStyle.italic,
                        ),
                        onSelectionChanged: (selection, cause) {
                          if (selection.start != selection.end) {
                            final text = widget.chapter.chapterIntro.substring(
                              selection.start,
                              selection.end,
                            );
                            _handleTextSelection(text);
                          }
                        },
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Sections
                  ...widget.chapter.sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    final section = entry.value;
                    return _buildSection(section, index + 1);
                  }),

                  const SizedBox(height: 80), // Space for floating buttons
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BBText(
                        data: 'Selected Text Actions',
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

  Widget _buildSection(ChapterSection section, int sectionNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title - Selectable
        SelectableText(
          '$sectionNumber. ${section.sectionTitle}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: BBColors.primaryColor,
            height: 1.4,
          ),
          onSelectionChanged: (selection, cause) {
            if (selection.start != selection.end) {
              final fullText = '$sectionNumber. ${section.sectionTitle}';
              final text = fullText.substring(selection.start, selection.end);
              _handleTextSelection(text);
            }
          },
        ),
        const SizedBox(height: 12),

        // Section Content
        if (section.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SelectableText(
              section.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Colors.black87,
              ),
              onSelectionChanged: (selection, cause) {
                if (selection.start != selection.end) {
                  final text = section.content.substring(
                    selection.start,
                    selection.end,
                  );
                  _handleTextSelection(text);
                }
              },
            ),
          ),

        // Subsections - with null check
        if (section.subsections.isNotEmpty)
          ...section.subsections.asMap().entries.map((entry) {
            final subIndex = entry.key;
            final subsection = entry.value;
            return _buildSubsection(subsection, sectionNumber, subIndex + 1);
          }),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubsection(
    SubSection subsection,
    int sectionNumber,
    int subNumber,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subsection Title - Selectable
          SelectableText(
            '$sectionNumber.$subNumber ${subsection.subsectionTitle}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              height: 1.4,
            ),
            onSelectionChanged: (selection, cause) {
              if (selection.start != selection.end) {
                final fullText =
                    '$sectionNumber.$subNumber ${subsection.subsectionTitle}';
                final text = fullText.substring(selection.start, selection.end);
                _handleTextSelection(text);
              }
            },
          ),
          const SizedBox(height: 8),

          // Subsection Content
          SelectableText(
            subsection.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.7,
              color: Colors.black87,
            ),
            onSelectionChanged: (selection, cause) {
              if (selection.start != selection.end) {
                final text = subsection.content.substring(
                  selection.start,
                  selection.end,
                );
                _handleTextSelection(text);
              }
            },
          ),
        ],
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

// Chat with AI Screen
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
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'isUser': false,
      'message':
          'I can help you understand this text: "${widget.selectedText}"\n\nWhat would you like to know about it?',
      'timestamp': DateTime.now(),
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'isUser': true,
          'message': _messageController.text.trim(),
          'timestamp': DateTime.now(),
        });
        _isTyping = true;
      });

      _messageController.clear();
      _scrollToBottom();

      // Simulate AI response delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _messages.add({
              'isUser': false,
              'message':
                  'This is a simulated AI response to your question about the selected text.',
              'timestamp': DateTime.now(),
            });
            _isTyping = false;
          });
          _scrollToBottom();
        }
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const BBText(
          data: 'Chat with AI',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Context Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BBText(
                  data: 'Context from ${widget.chapterTitle}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: BBColors.primaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  widget.selectedText,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child:
                _messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          BBText(
                            data: 'Start a conversation',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        final message = _messages[index];
                        return _buildMessageBubble(
                          message['message'],
                          message['isUser'],
                        );
                      },
                    ),
          ),

          // Input Field
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                    onSubmitted: (_) => _sendMessage(),
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser ? BBColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: SelectableText(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value + delay) % 1.0;
        return Opacity(
          opacity: 0.3 + (animValue * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isTyping) {
          setState(() {});
        }
      },
    );
  }
}
