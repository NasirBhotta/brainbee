import 'package:brainbee/presentation/views/class/bloc/disscussion/bloc/discussion_bloc.dart';
import 'package:brainbee/presentation/views/class/models/disscussion_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';

class ClassForumScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return _ForumView(
      classId: classId,
      className: className,
      teacherName: teacherName,
    );
  }
}

class _ForumView extends StatefulWidget {
  final String classId;
  final String className;
  final String teacherName;

  const _ForumView({
    required this.classId,
    required this.className,
    required this.teacherName,
  });

  @override
  State<_ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<_ForumView> {
  @override
  void initState() {
    super.initState();
    context.read<DiscussionBloc>().add(
      FetchTopicsEvent(classId: widget.classId),
    );
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
      body: BlocBuilder<DiscussionBloc, DiscussionState>(
        builder: (context, state) {
          if (state is TopicsLoading) return _buildLoading();
          if (state is TopicsError) return _buildError(context, state);
          if (state is TopicsEmpty)
            return _buildTopicsList(context, [], state.generalTopic);
          if (state is TopicsLoaded)
            return _buildTopicsList(context, state.topics, state.generalTopic);
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewTopicInfo(context),
        backgroundColor: BBColors.primaryBlue.withOpacity(0.8),
        icon: const Icon(Icons.info_outline, color: Colors.white),
        label: const Text('New Topic?', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
      ),
    );
  }

  Widget _buildError(BuildContext context, TopicsError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.isNetworkError ? Icons.wifi_off : Icons.error_outline,
            size: 64,
            color: BBColors.alertRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load discussions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () => context.read<DiscussionBloc>().add(
                  FetchTopicsEvent(classId: widget.classId),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsList(
    BuildContext context,
    List<DiscussionTopic> topics,
    DiscussionTopic generalTopic,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DiscussionBloc>().add(
          FetchTopicsEvent(classId: widget.classId),
        );
        await context.read<DiscussionBloc>().stream.firstWhere(
          (s) => s is! TopicsLoading,
        );
      },
      color: BBColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildGeneralTopicCard(context, generalTopic);
          return _buildTopicCard(context, topics[index - 1]);
        },
      ),
    );
  }

  Widget _buildGeneralTopicCard(BuildContext context, DiscussionTopic topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: BBColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToChat(context, topic),
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
            padding: const EdgeInsets.all(16),
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
                            topic.title,
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
                        '${topic.messageCount} messages',
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

  Widget _buildTopicCard(BuildContext context, DiscussionTopic topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToChat(context, topic),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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

  void _navigateToChat(BuildContext context, DiscussionTopic topic) {
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
  }

  void _showNewTopicInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: BBColors.primaryBlue, size: 24),
                SizedBox(width: 8),
                Text('Information'),
              ],
            ),
            content: const Text(
              'Only teachers can create new discussion topics.\n\nUse the General Discussion for open conversations.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }
}

// ============================================
// lib/presentation/views/class/UI/discussion/bb_discussion_chat.dart
// ============================================
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              DiscussionBloc(repository: context.read())
                ..add(FetchMessagesEvent(topicId: widget.topic.id)),
      child: Scaffold(
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
          children: [
            Expanded(child: _buildMessagesList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return BlocConsumer<DiscussionBloc, DiscussionState>(
      listener: (context, state) {
        if (state is MessagesLoaded) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }
        if (state is MessageSendError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: BBColors.alertRed,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MessagesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
            ),
          );
        }
        if (state is MessagesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: BBColors.alertRed,
                ),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      () => context.read<DiscussionBloc>().add(
                        FetchMessagesEvent(topicId: widget.topic.id),
                      ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is MessagesLoaded) {
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.messages.length,
            itemBuilder:
                (context, index) => _buildMessageBubble(state.messages[index]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessageBubble(DiscussionMessage message) {
    final isCurrentUser = message.senderName == 'You';
    final isTeacher = message.senderRole == 'teacher';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
    return BlocBuilder<DiscussionBloc, DiscussionState>(
      builder: (context, state) {
        final isSending = state is MessagesLoaded && state.isSending;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: BBColors.borderGray, width: 1),
            ),
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
                  onSubmitted: isSending ? null : (_) => _sendMessage(context),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    isSending ? BBColors.disabledText : BBColors.primaryColor,
                child:
                    isSending
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () => _sendMessage(context),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(BuildContext context) {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    context.read<DiscussionBloc>().add(
      SendMessageEvent(topicId: widget.topic.id, message: message),
    );
    _messageController.clear();
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

  String _formatMessageTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
