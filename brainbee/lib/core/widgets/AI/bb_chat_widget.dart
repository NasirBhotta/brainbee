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

  const BbChatWidget({super.key, required this.chatType});

  @override
  _AiTutorChatScreenState createState() => _AiTutorChatScreenState();
}

class _AiTutorChatScreenState extends State<BbChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> recentMessages = [];
  String studentId = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BotBloc, BotState>(
      listener: (context, state) {
        final student = context.read<StudentBloc>().state;
        studentId = (student as StudentDataLoaded).student.id;

        if (state is SendMessageInProgress) {
          setState(() {
            isLoading = true;
          });
        } else if (state is SendMessageSuccess) {
          setState(() {
            recentMessages.add(
              ChatMessage(
                sender: 'ai',
                content: state.response,
                timestamp: DateTime.now(),
              ),
            );
            isLoading = false;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else if (state is SendMessageFailure) {
          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
                context.read<BotBloc>().add(
                  const LoadHistory(studentId: '6883d69eed4b4da8e4cfd921'),
                );
              },
            ),
            title: const Text(
              'Ai Tutor',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Chat messages
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children:
                      widget.chatType == ChatType.historyChat
                          ? [
                            // First user message
                            _buildUserMessage(
                              "Hey! Can you help me with my studies?",
                            ),

                            // First AI response
                            _buildAiMessage(
                              "Hi there! Absolutely! I'm here to help you with all kinds of subjects. Whether it's science, history, literature, or anything else - just ask away! What subject are you working on today? 📚✨",
                            ),

                            // Second user message
                            _buildUserMessage(
                              "I have a history test tomorrow about World War II",
                            ),

                            // Second AI response
                            _buildAiMessage(
                              "Great! World War II is such an important topic. I can help you review key events, dates, major battles, and important figures. What specific area would you like to focus on? Maybe the causes of the war, major battles, or the aftermath? Let me know what you're struggling with most! 🌍⚔️",
                            ),

                            // Third user messageasfd
                            _buildUserMessage(
                              "What were the main causes that started the war?",
                            ),

                            // Third AI response
                            _buildAiMessage(
                              "Excellent question! There were several key causes that led to WWII:\n\n• The harsh terms of the Treaty of Versailles after WWI left Germany economically devastated and resentful\n\n• The rise of totalitarian regimes in Germany, Italy, and Japan\n\n• Economic instability from the Great Depression\n\n• Failure of the League of Nations to maintain peace\n\n• Germany's aggressive expansion into Austria and Czechoslovakia\n\nThe immediate trigger was Germany's invasion of Poland in September 1939, which led Britain and France to declare war. Does this help clarify things for your test? 🎯",
                            ),

                            // Fourth user message
                            _buildUserMessage(
                              "Yes! That's really helpful. Thanks!",
                            ),

                            // Fourth AI response
                            _buildAiMessage(
                              "You're so welcome! I'm glad I could help clarify that for you. History can be complex, but breaking it down into key points like this makes it much easier to remember for tests.\n\nGood luck with your exam tomorrow! You've got this! If you need help with any other topics or have more questions, just let me know. I'm here whenever you need study support! 💪😊",
                            ),
                          ]
                          : recentMessages.isEmpty
                          ? [
                            _buildAiMessage(
                              "Hello! I'm your AI tutor. How can I assist you today?",
                            ),
                          ]
                          : recentMessages.map((e) {
                            if (e.sender == 'student') {
                              return _buildUserMessage(e.content);
                            } else {
                              return _buildAiMessage(e.content);
                            }
                          }).toList(),
                ),
              ),

              // Bottom input area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  children: [
                    // Message input
                    Form(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _messageController,
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
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                fillColor: BBColors.lightGrayBG,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(0, 0, 0, 0),
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(0, 139, 75, 75),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap:
                                (state is SendMessageInProgress)
                                    ? null
                                    : () {
                                      if (_messageController.text.isEmpty) {
                                        return;
                                      }

                                      setState(() {
                                        recentMessages.add(
                                          ChatMessage(
                                            sender: 'student',
                                            content: _messageController.text,
                                            timestamp: DateTime.now(),
                                          ),
                                        );
                                      });

                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (_scrollController.hasClients) {
                                              _scrollController.animateTo(
                                                _scrollController
                                                    .position
                                                    .maxScrollExtent,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeOut,
                                              );
                                            }
                                          });

                                      context.read<BotBloc>().add(
                                        SendMessage(
                                          studentId: studentId,
                                          question: _messageController.text,
                                        ),
                                      );
                                      _messageController.clear();
                                    },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color:
                                    (state is SendMessageFailure)
                                        ? BBColors.disabledText
                                        : BBColors.successGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Disclaimer text
                    Text(
                      'B-bot may make mistakes, please double-check the answers.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Bottom indicator
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
              ),
            ],
          ),
        );
      },
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
                'N',
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
