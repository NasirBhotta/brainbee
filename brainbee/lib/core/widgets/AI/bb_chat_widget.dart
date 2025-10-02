import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/bot/UI/bb_initial_bot_screen.dart';
import 'package:brainbee/presentation/views/bot/bloc/bot_bloc.dart';
import 'package:brainbee/presentation/views/bot/models/chat_message.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbChatWidget extends StatefulWidget {
  final ChatType chatType;
  final String? sessionId;
  final String? selectedText;

  const BbChatWidget({
    super.key,
    this.sessionId,
    required this.chatType,
    this.selectedText,
  });

  @override
  State<BbChatWidget> createState() => _BbChatWidgetState();
}

class _BbChatWidgetState extends State<BbChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> recentMessages = [];
  String studentId = '';
  bool isLoading = false;
  String sessionId = '';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Get student ID immediately

    if (widget.selectedText == '' || widget.selectedText == null) {
    } else {
      _messageController.text = widget.selectedText!;
    }

    final studentState = context.read<StudentBloc>().state;
    if (studentState is StudentDataLoaded) {
      studentId = studentState.student.id;
    }

    // Load session-specific chat if needed
    if (widget.sessionId != null && widget.chatType == ChatType.historyChat) {
      sessionId = widget.sessionId!;
      context.read<BotBloc>().add(
        LoadSessionSpecificChat(sessionId: widget.sessionId!),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();

    setState(() {
      recentMessages.add(
        ChatMessage(
          sender: 'user',
          content: messageText,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();

    context.read<BotBloc>().add(
      SendMessage(
        studentId: studentId,
        question: messageText,
        sessionId: sessionId.isEmpty ? null : sessionId,
      ),
    );

    _messageController.clear();
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BotBloc, BotState>(
      listener: (context, state) {
        // Update student ID if not already set
        final student = context.read<StudentBloc>().state;
        if (student is StudentDataLoaded && studentId.isEmpty) {
          studentId = student.student.id;
        }

        switch (state) {
          case SendMessageInProgress():
            setState(() => isLoading = true);
            break;

          case SendMessageSuccess():
            setState(() {
              sessionId = state.sessionId;
              recentMessages.add(
                ChatMessage(
                  sender: 'ai',
                  content: state.response,
                  timestamp: DateTime.now(),
                ),
              );
              isLoading = false;
            });
            _scrollToBottom();
            break;

          case SendMessageFailure():
            setState(() => isLoading = false);
            _showErrorSnackBar(state.error);
            break;

          case SessionSpecificChatLoaded():
            setState(() {
              recentMessages = List.from(state.chat);
            });
            _scrollToBottom();
            break;

          case SessionSpecificChatFailure():
            _showErrorSnackBar(state.error);
            break;

          default:
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(child: _buildChatList()),
              _buildBottomInputArea(state),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
          // Use dynamic studentId instead of hardcoded value
          if (studentId.isNotEmpty) {
            context.read<BotBloc>().add(LoadHistory(studentId: studentId));
          }
        },
      ),
      title: const Text(
        'AI Tutor',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildChatList() {
    return BlocBuilder<BotBloc, BotState>(
      builder: (context, state) {
        if (state is SessionSpecificChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: _getChatMessages(),
        );
      },
    );
  }

  List<Widget> _getChatMessages() {
    // Always use recentMessages for displaying chat
    if (recentMessages.isEmpty) {
      if (widget.chatType == ChatType.historyChat) {
        // Show loading or empty state for history chat
        return [const Center(child: CircularProgressIndicator())];
      } else {
        // Show initial AI message for new chat
        return [
          _buildAiMessage(
            "Hello! I'm your AI tutor. How can I assist you today?",
          ),
        ];
      }
    }

    List<Widget> chatWidgets =
        recentMessages.map((message) {
          return message.sender == 'user'
              ? _buildUserMessage(message.content)
              : _buildAiMessage(message.content);
        }).toList();

    // Add typing indicator if message is being sent
    if (isLoading) {
      chatWidgets.add(_buildTypingIndicator()); // <-- HERE IT'S USED!
    }

    return chatWidgets;
  }

  Widget _buildBottomInputArea(BotState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          _buildMessageInput(state),
          const SizedBox(height: 12),
          Text(
            'B-bot may make mistakes, please double-check the answers.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            width: 134,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BotState state) {
    final isDisabled =
        state is SendMessageInProgress || state is SessionSpecificChatLoading;

    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _messageController,
            enabled: !isDisabled,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 20,
              ),
              label: Text(
                'Ask B-Bot',
                style: context.textStyle.labelSmall?.copyWith(
                  color: BBColors.disabledText,
                ),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              fillColor: BBColors.lightGrayBG,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(30),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onFieldSubmitted: (_) => !isDisabled ? _sendMessage() : null,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: !isDisabled ? _sendMessage : null,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDisabled ? BBColors.disabledText : BBColors.successGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(String message) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: BBColors.successGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade200,
              child: const Text(
                'S', // Changed from 'N' to 'S' for Student
                style: TextStyle(fontSize: 16, color: BBColors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAiMessage(String message) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.purple.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'AI',
                  style: TextStyle(fontSize: 16, color: BBColors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(
                          Icons.thumb_down_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.copy_outlined, size: 18, color: Colors.grey),
                        SizedBox(width: 16),
                        Icon(
                          Icons.refresh_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.purple.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'AI',
                  style: TextStyle(fontSize: 16, color: BBColors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedDot(0),
                  const SizedBox(width: 4),
                  _buildAnimatedDot(1),
                  const SizedBox(width: 4),
                  _buildAnimatedDot(2),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAnimatedDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        // Restart animation to create continuous loop
        if (mounted && isLoading) {
          Future.delayed(Duration(milliseconds: index * 200), () {
            if (mounted) setState(() {});
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
