import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

class ReportCardShareUtility {
  // Share report as text
  static Future<void> shareAsText({
    required int score,
    required int opponentScore,
    required bool won,
    required Map<String, dynamic> quizAnalytics,
    required List<Map<String, dynamic>> improvements,
  }) async {
    final String shareText = _generateShareText(
      score: score,
      opponentScore: opponentScore,
      won: won,
      quizAnalytics: quizAnalytics,
      improvements: improvements,
    );

    await Share.share(shareText, subject: 'My Quiz Battle Report Card');
  }

  // Share report with PDF file
  static Future<void> shareWithPDF({
    required File pdfFile,
    required int score,
    required int opponentScore,
    required bool won,
  }) async {
    final String message = _generateSimpleShareText(score, opponentScore, won);

    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      text: message,
      subject: 'My Quiz Battle Report Card',
    );
  }

  // Share as image (screenshot of widget)
  static Future<void> shareAsImage({
    required GlobalKey widgetKey,
    required int score,
    required int opponentScore,
    required bool won,
  }) async {
    try {
      // Capture widget as image
      RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/quiz_report_${DateTime.now().millisecondsSinceEpoch}.png';
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // Share the image
      final String message = _generateSimpleShareText(
        score,
        opponentScore,
        won,
      );
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: message,
        subject: 'My Quiz Battle Report Card',
      );
    } catch (e) {
      throw Exception('Failed to capture and share image: $e');
    }
  }

  // Share to specific social media platforms
  static Future<void> shareToSocialMedia({
    required String platform,
    required int score,
    required int opponentScore,
    required bool won,
    required Map<String, dynamic> quizAnalytics,
    File? pdfFile,
    File? imageFile,
  }) async {
    String shareText;

    switch (platform.toLowerCase()) {
      case 'twitter':
        shareText = _generateTwitterShareText(
          score,
          opponentScore,
          won,
          quizAnalytics,
        );
        break;
      case 'facebook':
        shareText = _generateFacebookShareText(
          score,
          opponentScore,
          won,
          quizAnalytics,
        );
        break;
      case 'instagram':
        shareText = _generateInstagramShareText(score, opponentScore, won);
        break;
      case 'whatsapp':
        shareText = _generateWhatsAppShareText(
          score,
          opponentScore,
          won,
          quizAnalytics,
        );
        break;
      default:
        shareText = _generateShareText(
          score: score,
          opponentScore: opponentScore,
          won: won,
          quizAnalytics: quizAnalytics,
          improvements: [],
        );
    }

    if (imageFile != null) {
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: shareText,
        subject: 'My Quiz Battle Report',
      );
    } else if (pdfFile != null) {
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: shareText,
        subject: 'My Quiz Battle Report',
      );
    } else {
      await Share.share(shareText, subject: 'My Quiz Battle Report');
    }
  }

  // Generate comprehensive share text
  static String _generateShareText({
    required int score,
    required int opponentScore,
    required bool won,
    required Map<String, dynamic> quizAnalytics,
    required List<Map<String, dynamic>> improvements,
  }) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('🧠 Quiz Battle Report Card 🧠');
    buffer.writeln('');
    buffer.writeln('📊 RESULTS:');
    buffer.writeln(won ? '🏆 VICTORY!' : '😅 DEFEAT');
    buffer.writeln('My Score: $score');
    buffer.writeln('Opponent Score: $opponentScore');
    buffer.writeln('');
    buffer.writeln('📈 PERFORMANCE:');
    buffer.writeln('✅ Accuracy: ${quizAnalytics['accuracy']}%');
    buffer.writeln(
      '📝 Questions Answered: ${quizAnalytics['correctAnswers']}/${quizAnalytics['totalQuestions']}',
    );
    buffer.writeln(
      '⏱️ Average Time per Question: ${quizAnalytics['avgTimePerQuestion']}s',
    );
    buffer.writeln('📅 Date: ${quizAnalytics['date']}');

    if (improvements.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('💡 TOP IMPROVEMENT AREAS:');
      for (int i = 0; i < improvements.length && i < 3; i++) {
        buffer.writeln('• ${improvements[i]['title']}');
      }
    }

    buffer.writeln('');
    buffer.writeln('📱 Generated by BrainBee Quiz App');

    return buffer.toString();
  }

  // Generate simple share text
  static String _generateSimpleShareText(
    int score,
    int opponentScore,
    bool won,
  ) {
    return '🧠 Just completed a Quiz Battle!\n'
        '${won ? '🏆 WON' : '😅 LOST'} with a score of $score vs $opponentScore\n'
        '📱 BrainBee Quiz App';
  }

  // Platform-specific share texts
  static String _generateTwitterShareText(
    int score,
    int opponentScore,
    bool won,
    Map<String, dynamic> analytics,
  ) {
    return '🧠 Quiz Battle Complete!\n'
        '${won ? '🏆' : '😅'} $score vs $opponentScore\n'
        '📊 ${analytics['accuracy']}% accuracy\n'
        '#QuizBattle #BrainBee #LearningIsFun';
  }

  static String _generateFacebookShareText(
    int score,
    int opponentScore,
    bool won,
    Map<String, dynamic> analytics,
  ) {
    return '🧠 Just finished an epic Quiz Battle on BrainBee!\n\n'
        'Results: ${won ? '🏆 VICTORY!' : '😅 Good effort!'}\n'
        'My Score: $score\n'
        'Opponent Score: $opponentScore\n'
        'Accuracy: ${analytics['accuracy']}%\n\n'
        'Who wants to challenge me next? 💪\n\n'
        '#QuizBattle #BrainBee #Knowledge #Learning';
  }

  static String _generateInstagramShareText(
    int score,
    int opponentScore,
    bool won,
  ) {
    return '🧠✨ Quiz Battle Results ✨🧠\n\n'
        '${won ? '🏆 CHAMPION' : '😅 FIGHTER'}\n'
        '$score vs $opponentScore\n\n'
        '#QuizBattle #BrainBee #SmartIsCool #Challenge';
  }

  static String _generateWhatsAppShareText(
    int score,
    int opponentScore,
    bool won,
    Map<String, dynamic> analytics,
  ) {
    return '🧠 *Quiz Battle Report* 🧠\n\n'
        '*Result:* ${won ? '🏆 WON!' : '😅 Lost'}\n'
        '*My Score:* $score\n'
        '*Opponent:* $opponentScore\n'
        '*Accuracy:* ${analytics['accuracy']}%\n'
        '*Questions:* ${analytics['correctAnswers']}/${analytics['totalQuestions']} correct\n\n'
        'Want to challenge me? Let\'s battle! 💪\n\n'
        '_Generated by BrainBee Quiz App_ 📱';
  }

  // Show share options dialog
  static void showShareDialog({
    required BuildContext context,
    required int score,
    required int opponentScore,
    required bool won,
    required Map<String, dynamic> quizAnalytics,
    required List<Map<String, dynamic>> improvements,
    File? pdfFile,
    GlobalKey? widgetKey,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share Your Report Card',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Share as text
              ListTile(
                leading: const Icon(Icons.text_fields, color: Colors.blue),
                title: const Text('Share as Text'),
                subtitle: const Text('Share summary as text message'),
                onTap: () {
                  Navigator.pop(context);
                  shareAsText(
                    score: score,
                    opponentScore: opponentScore,
                    won: won,
                    quizAnalytics: quizAnalytics,
                    improvements: improvements,
                  );
                },
              ),

              // Share PDF if available
              if (pdfFile != null)
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('Share PDF Report'),
                  subtitle: const Text('Share detailed PDF report'),
                  onTap: () {
                    Navigator.pop(context);
                    shareWithPDF(
                      pdfFile: pdfFile,
                      score: score,
                      opponentScore: opponentScore,
                      won: won,
                    );
                  },
                ),

              // Share as image if widget key available
              if (widgetKey != null)
                ListTile(
                  leading: const Icon(Icons.image, color: Colors.green),
                  title: const Text('Share as Image'),
                  subtitle: const Text('Share screenshot of report'),
                  onTap: () {
                    Navigator.pop(context);
                    shareAsImage(
                      widgetKey: widgetKey,
                      score: score,
                      opponentScore: opponentScore,
                      won: won,
                    );
                  },
                ),

              const Divider(),

              // Social media options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(
                    icon: Icons.chat,
                    label: 'WhatsApp',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      shareToSocialMedia(
                        platform: 'whatsapp',
                        score: score,
                        opponentScore: opponentScore,
                        won: won,
                        quizAnalytics: quizAnalytics,
                        pdfFile: pdfFile,
                      );
                    },
                  ),
                  _buildSocialButton(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      shareToSocialMedia(
                        platform: 'facebook',
                        score: score,
                        opponentScore: opponentScore,
                        won: won,
                        quizAnalytics: quizAnalytics,
                        pdfFile: pdfFile,
                      );
                    },
                  ),
                  _buildSocialButton(
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      shareToSocialMedia(
                        platform: 'instagram',
                        score: score,
                        opponentScore: opponentScore,
                        won: won,
                        quizAnalytics: quizAnalytics,
                        pdfFile: pdfFile,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
