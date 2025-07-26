// screens/class_forum_screen.dart
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';

// models/discussion_models.dart
class DiscussionMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'teacher' or 'student'
  final String message;
  final DateTime timestamp;
  final String? topicId;

  DiscussionMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.topicId,
  });
}

class DiscussionTopic {
  final String id;
  final String title;
  final String createdBy;
  final DateTime createdAt;
  final int messageCount;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    required this.messageCount,
  });
}

class ClassForumScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String teacherName;

  const ClassForumScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.teacherName,
  });

  @override
  State<ClassForumScreen> createState() => _ClassForumScreenState();
}

class _ClassForumScreenState extends State<ClassForumScreen> {
  bool _isLoading = false;
  bool _hasError = false;
  List<DiscussionTopic> _topics = [];
  late DiscussionTopic _generalTopic;

  @override
  void initState() {
    super.initState();
    _initializeGeneralTopic();
    _loadDiscussions();
  }

  void _initializeGeneralTopic() {
    // Built-in General Discussion - always available
    _generalTopic = DiscussionTopic(
      id: 'general_${widget.classId}',
      title: 'General Discussion',
      createdBy: 'System',
      createdAt: DateTime.now().subtract(
        const Duration(days: 30),
      ), // Created when class was made
      messageCount: 0, // Will be updated from API
    );
  }

  Future<void> _loadDiscussions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - only teacher-created topics
      _topics = [
        DiscussionTopic(
          id: '1',
          title: 'Chapter 3: Algebra Questions',
          createdBy: 'Mr. Johnson',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          messageCount: 12,
        ),
        DiscussionTopic(
          id: '2',
          title: 'Homework Assignment - Due Friday',
          createdBy: 'Mr. Johnson',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          messageCount: 8,
        ),
        DiscussionTopic(
          id: '3',
          title: 'Midterm Exam Preparation',
          createdBy: 'Mr. Johnson',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          messageCount: 15,
        ),
      ];

      // Update general topic message count (simulate API response)
      _generalTopic = DiscussionTopic(
        id: _generalTopic.id,
        title: _generalTopic.title,
        createdBy: _generalTopic.createdBy,
        createdAt: _generalTopic.createdAt,
        messageCount: 25, // Updated from API
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _showNewTopicDialog() {
    // Show message that only teachers can create topics
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: BBColors.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Only teachers can create new discussion topics.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                ),
                const SizedBox(height: 12),
                Text(
                  'You can participate in existing discussions or use the General Discussion for open conversations.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Got it',
                  style: TextStyle(color: BBColors.primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to General Discussion
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ClassDiscussionScreen(
                            classId: widget.classId,
                            className: widget.className,
                            topic: _generalTopic,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                ),
                child: const Text('Go to General Discussion'),
              ),
            ],
          ),
    );
  }

  void _createNewTopic(String title) {
    // This method is now unused since students can't create topics
    // Keeping for potential future use or teacher app integration
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        backgroundColor: BBColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.className} Forum',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Teacher: ${widget.teacherName}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewTopicDialog,
        backgroundColor: BBColors.primaryBlue.withOpacity(0.8),
        icon: const Icon(Icons.info_outline, color: Colors.white),
        label: Text(
          'New Topic?',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
        ),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_topics.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadDiscussions,
      color: BBColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _topics.length + 1, // +1 for General Discussion
        itemBuilder: (context, index) {
          if (index == 0) {
            // Always show General Discussion first
            return _buildGeneralTopicCard();
          }
          return _buildTopicCard(_topics[index - 1]);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: BBColors.alertRed),
          const SizedBox(height: 16),
          Text(
            'Failed to load discussions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BBColors.darkHeading),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _loadDiscussions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                ),
                child: const Text('Retry'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadDiscussions,
      color: BBColors.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Always show General Discussion even when no other topics
          _buildGeneralTopicCard(),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: BBColors.disabledText,
                ),
                const SizedBox(height: 16),
                Text(
                  'No specific topics yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your teacher will create discussion topics\nMeanwhile, use General Discussion to chat!',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTopicCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: BBColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ClassDiscussionScreen(
                    classId: widget.classId,
                    className: widget.className,
                    topic: _generalTopic,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                BBColors.primaryColor.withOpacity(0.05),
                BBColors.secondaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: BBColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.forum,
                        color: BBColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _generalTopic.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: BBColors.darkHeading,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Open discussion for all students',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: BBColors.bodyText),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: BBColors.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 16,
                          color: BBColors.bodyText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'All students can participate',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: BBColors.bodyText),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BBColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_generalTopic.messageCount} messages',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(DiscussionTopic topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ClassDiscussionScreen(
                    classId: widget.classId,
                    className: widget.className,
                    topic: topic,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      topic.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: BBColors.darkHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: BBColors.disabledText,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: BBColors.bodyText),
                  const SizedBox(width: 4),
                  Text(
                    'Started by ${topic.createdBy}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: BBColors.bodyText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(topic.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BBColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${topic.messageCount} messages',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BBColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

// screens/class_discussion_screen.dart
class ClassDiscussionScreen extends StatefulWidget {
  final String classId;
  final String className;
  final DiscussionTopic topic;

  const ClassDiscussionScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.topic,
  });

  @override
  State<ClassDiscussionScreen> createState() => _ClassDiscussionScreenState();
}

class _ClassDiscussionScreenState extends State<ClassDiscussionScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasError = false;
  List<DiscussionMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock messages
      _messages = [
        DiscussionMessage(
          id: '1',
          senderId: 'teacher1',
          senderName: 'Mr. Johnson',
          senderRole: 'teacher',
          message:
              widget.topic.id.contains('general')
                  ? 'Welcome to the general discussion! Feel free to ask questions, share thoughts, or help each other with studies.'
                  : 'Welcome to our discussion forum! Feel free to ask any questions about the chapter.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          topicId: widget.topic.id,
        ),
        if (widget.topic.id.contains('general')) ...[
          DiscussionMessage(
            id: '2',
            senderId: 'student1',
            senderName: 'Sarah Ahmed',
            senderRole: 'student',
            message:
                'Hi everyone! Can someone help me understand the homework from yesterday?',
            timestamp: DateTime.now().subtract(
              const Duration(hours: 1, minutes: 30),
            ),
            topicId: widget.topic.id,
          ),
          DiscussionMessage(
            id: '3',
            senderId: 'student2',
            senderName: 'Ahmed Ali',
            senderRole: 'student',
            message: 'Sure Sarah! Which part are you having trouble with?',
            timestamp: DateTime.now().subtract(
              const Duration(hours: 1, minutes: 25),
            ),
            topicId: widget.topic.id,
          ),
          DiscussionMessage(
            id: '4',
            senderId: 'student1',
            senderName: 'Sarah Ahmed',
            senderRole: 'student',
            message:
                'The quadratic equations part. I keep getting confused with the formula.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
            topicId: widget.topic.id,
          ),
        ] else ...[
          DiscussionMessage(
            id: '2',
            senderId: 'student1',
            senderName: 'Sarah Ahmed',
            senderRole: 'student',
            message:
                'Thank you sir! I have a question about quadratic equations.',
            timestamp: DateTime.now().subtract(
              const Duration(hours: 1, minutes: 30),
            ),
            topicId: widget.topic.id,
          ),
          DiscussionMessage(
            id: '3',
            senderId: 'teacher1',
            senderName: 'Mr. Johnson',
            senderRole: 'teacher',
            message: 'Sure Sarah, go ahead with your question.',
            timestamp: DateTime.now().subtract(
              const Duration(hours: 1, minutes: 25),
            ),
            topicId: widget.topic.id,
          ),
        ],
      ];

      setState(() {
        _isLoading = false;
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final newMessage = DiscussionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      senderRole: 'student', // Replace with actual user role
      message: message,
      timestamp: DateTime.now(),
      topicId: widget.topic.id,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();

    // Scroll to bottom after adding message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Simulate sending to server
    // In real implementation, call API here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        backgroundColor: BBColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.topic.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.className,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [Expanded(child: _buildMessagesList()), _buildMessageInput()],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
        ),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: BBColors.alertRed),
          const SizedBox(height: 16),
          Text(
            'Failed to load messages',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BBColors.darkHeading),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(DiscussionMessage message) {
    final isCurrentUser = message.senderName == 'You';
    final isTeacher = message.senderRole == 'teacher';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  isTeacher ? BBColors.primaryBlue : BBColors.primaryColor,
              child: Text(
                message.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Row(
                    children: [
                      Text(
                        message.senderName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.bodyText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isTeacher) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: BBColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Teacher',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: BBColors.primaryBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? BBColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isCurrentUser ? Colors.white : BBColors.darkHeading,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BBColors.disabledText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: BBColors.primaryColor,
              child: Text(
                message.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BBColors.borderGray, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: BBColors.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: BBColors.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: BBColors.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 24,
            backgroundColor: BBColors.primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
