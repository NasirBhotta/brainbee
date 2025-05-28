// import 'package:brainbee/core/constants/bb_colors.dart';
// import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
// import 'package:flutter/material.dart';

// class BbHistoryChat extends StatefulWidget {
//   const BbHistoryChat({super.key});

//   @override
//   _AiTutorChatScreenState createState() => _AiTutorChatScreenState();
// }

// class _AiTutorChatScreenState extends State<BbHistoryChat> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Ai Tutor',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // Chat messages
//           Expanded(
//             child: ListView(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(16),
//               children: [
//                 // First user message
//                 _buildUserMessage("Hey! Can you help me with my studies?"),
//                 const SizedBox(height: 16),

//                 // First AI response
//                 _buildAiMessage(
//                   "Hi there! Absolutely! I'm here to help you with all kinds of subjects. Whether it's science, history, literature, or anything else - just ask away! What subject are you working on today? 📚✨",
//                 ),
//                 const SizedBox(height: 16),

//                 // Second user message
//                 _buildUserMessage(
//                   "I have a history test tomorrow about World War II",
//                 ),
//                 const SizedBox(height: 16),

//                 // Second AI response
//                 _buildAiMessage(
//                   "Great! World War II is such an important topic. I can help you review key events, dates, major battles, and important figures. What specific area would you like to focus on? Maybe the causes of the war, major battles, or the aftermath? Let me know what you're struggling with most! 🌍⚔️",
//                 ),
//                 const SizedBox(height: 16),

//                 // Third user message
//                 _buildUserMessage(
//                   "What were the main causes that started the war?",
//                 ),
//                 const SizedBox(height: 16),

//                 // Third AI response
//                 _buildAiMessage(
//                   "Excellent question! There were several key causes that led to WWII:\n\n• The harsh terms of the Treaty of Versailles after WWI left Germany economically devastated and resentful\n\n• The rise of totalitarian regimes in Germany, Italy, and Japan\n\n• Economic instability from the Great Depression\n\n• Failure of the League of Nations to maintain peace\n\n• Germany's aggressive expansion into Austria and Czechoslovakia\n\nThe immediate trigger was Germany's invasion of Poland in September 1939, which led Britain and France to declare war. Does this help clarify things for your test? 🎯",
//                 ),
//                 const SizedBox(height: 16),

//                 // Fourth user message
//                 _buildUserMessage("Yes! That's really helpful. Thanks!"),
//                 const SizedBox(height: 16),

//                 // Fourth AI response
//                 _buildAiMessage(
//                   "You're so welcome! I'm glad I could help clarify that for you. History can be complex, but breaking it down into key points like this makes it much easier to remember for tests.\n\nGood luck with your exam tomorrow! You've got this! If you need help with any other topics or have more questions, just let me know. I'm here whenever you need study support! 💪😊",
//                 ),
//               ],
//             ),
//           ),

//           // Bottom input area
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border(top: BorderSide(color: Colors.grey.shade200)),
//             ),
//             child: Column(
//               children: [
//                 // Message input
//                 Form(
//                   child: Row(
//                     children: [
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                             contentPadding: const EdgeInsets.symmetric(
//                               vertical: 5,
//                               horizontal: 20,
//                             ),
//                             label: Text(
//                               'Ask B-Bot',
//                               style: context.textStyle.labelSmall?.copyWith(
//                                 color: BBColors.disabledText,
//                               ),
//                             ),
//                             floatingLabelBehavior: FloatingLabelBehavior.never,
//                             fillColor: BBColors.lightGrayBG,
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: const BorderSide(
//                                 color: Colors.transparent,
//                               ),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: const BorderSide(
//                                 color: Color.fromARGB(0, 0, 0, 0),
//                               ),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             border: const OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Color.fromARGB(0, 139, 75, 75),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Container(
//                         width: 32,
//                         height: 32,
//                         decoration: const BoxDecoration(
//                           color: BBColors.successGreen,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.send,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 // Disclaimer text
//                 Text(
//                   'B-bot may make mistakes, please double-check the answers.',
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 // Bottom indicator
//                 Container(
//                   width: 134,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(2.5),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserMessage(String message) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.7,
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: BBColors.successGreen,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             message,
//             style: const TextStyle(color: Colors.white, fontSize: 16),
//           ),
//         ),
//         const SizedBox(width: 8),
//         CircleAvatar(
//           radius: 16,
//           backgroundColor: Colors.green.shade200,
//           child: const Text(
//             'N',
//             style: TextStyle(fontSize: 16, color: BBColors.white),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAiMessage(String message) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: Colors.purple.shade400,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Center(
//             child: Text(
//               'AI',
//               style: TextStyle(fontSize: 16, color: BBColors.white),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   message,
//                   style: const TextStyle(fontSize: 16, height: 1.4),
//                 ),
//                 const SizedBox(height: 12),
//                 const Row(
//                   children: [
//                     Icon(
//                       Icons.thumb_down_outlined,
//                       size: 18,
//                       color: Colors.grey,
//                     ),
//                     SizedBox(width: 16),
//                     Icon(Icons.copy_outlined, size: 18, color: Colors.grey),
//                     SizedBox(width: 16),
//                     Icon(Icons.refresh_outlined, size: 18, color: Colors.grey),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
// }
