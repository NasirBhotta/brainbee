import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart'; // Add this import
import 'package:brainbee/core/models/bb_question.dart';
import 'package:share_plus/share_plus.dart';

class ReportCardPDFGenerator {
  static Future<File> generatePDF({
    required int score,
    required int opponentScore,
    required bool won,
    required List<Question> questions,
    required List<int?> userAnswers,
    required int timeSpent,
    required Map<String, dynamic> quizAnalytics,
    required List<Map<String, dynamic>> questionAnalysis,
    required Map<String, dynamic> performanceMetrics,
    required List<Map<String, dynamic>> improvements,
    required autoOpen, // Add this parameter
    required bool shareFile,
  }) async {
    final pdf = pw.Document();

    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(
              won,
              score,
              opponentScore,
              quizAnalytics,
              timeSpent,
              ttf,
            ),
            pw.SizedBox(height: 20),
            _buildQuizSummary(quizAnalytics, ttf),
            pw.SizedBox(height: 20),
            _buildPerformanceMetrics(performanceMetrics, quizAnalytics, ttf),
            pw.SizedBox(height: 20),
            _buildQuestionAnalysis(questionAnalysis, ttf),
            pw.SizedBox(height: 20),
            _buildImprovementSuggestions(improvements, ttf),
          ];
        },
      ),
    );

    // Save PDF to device
    final output = await getApplicationDocumentsDirectory();
    final file = File(
      '${output.path}/quiz_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    // Automatically open the PDF if requested
    if (autoOpen && !shareFile) {
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        print('Error opening PDF: ${result.message}');
        // Optionally show a snackbar or dialog to the user
      }
    }

    if (shareFile && !autoOpen) {
      try {
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Check out my Quiz Report Card! 📊\n\nScore: $score/${quizAnalytics['totalQuestions']}\nAccuracy: ${quizAnalytics['accuracy']}%\nResult: ${won ? "Victory! 🎉" : "Good effort! 💪"}',
          subject: 'Quiz Report Card - ${won ? "Victory!" : "Report"}',
        );
      } catch (e) {
        print('Error sharing PDF: $e');
      }
    }

    return file;
  }

  // ... rest of your existing methods remain the same ...

  static pw.Widget _buildHeader(
    bool won,
    int score,
    int opponentScore,
    Map<String, dynamic> quizAnalytics,
    int timeSpent,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: won ? PdfColors.green100 : PdfColors.red100,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: won ? PdfColors.green : PdfColors.red,
          width: 2,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Quiz Report Card',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.Text(
                won ? 'VICTORY!' : 'DEFEAT',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: won ? PdfColors.green : PdfColors.red,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCard(
                'Your Score',
                score.toString(),
                PdfColors.blue,
                font,
              ),
              _buildScoreCard(
                'Opponent Score',
                opponentScore.toString(),
                PdfColors.red,
                font,
              ),
              _buildScoreCard(
                'Time Spent',
                '${(timeSpent ~/ 60).toString().padLeft(2, '0')}:${(timeSpent % 60).toString().padLeft(2, '0')}',
                PdfColors.orange,
                font,
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Date: ${quizAnalytics['date']}',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildScoreCard(
    String label,
    String value,
    PdfColor color,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildQuizSummary(
    Map<String, dynamic> analytics,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Quiz Summary',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                'Total Questions',
                '${analytics['totalQuestions']}',
                font,
              ),
              _buildSummaryItem(
                'Correct Answers',
                '${analytics['correctAnswers']}',
                font,
              ),
              _buildSummaryItem('Accuracy', '${analytics['accuracy']}%', font),
              _buildSummaryItem(
                'Avg Time/Q',
                '${analytics['avgTimePerQuestion']}s',
                font,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, pw.Font font) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPerformanceMetrics(
    Map<String, dynamic> metrics,
    Map<String, dynamic> analytics,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Performance Metrics',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildMetricRow(
            'Accuracy',
            '${analytics['accuracy']}%',
            metrics['accuracyChange'],
            font,
          ),
          pw.SizedBox(height: 8),
          _buildMetricRow(
            'Speed',
            '${analytics['avgTimePerQuestion']}s/q',
            -metrics['speedChange'],
            font,
          ),
          pw.SizedBox(height: 8),
          _buildMetricRow(
            'Score',
            '${analytics['score']}',
            metrics['scoreChange'],
            font,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetricRow(
    String label,
    String value,
    dynamic change,
    pw.Font font,
  ) {
    final isPositive = change > 0;
    final changeText = '${isPositive ? '+' : ''}${change.toString()}';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 14)),
        pw.Row(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: pw.BoxDecoration(
                color: isPositive ? PdfColors.green100 : PdfColors.red100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                changeText,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  color: isPositive ? PdfColors.green : PdfColors.red,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildQuestionAnalysis(
    List<Map<String, dynamic>> analysis,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Question Analysis',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...analysis
              .take(10)
              .map((question) => _buildQuestionItem(question, font)),
          if (analysis.length > 10)
            pw.Text(
              '... and ${analysis.length - 10} more questions',
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: PdfColors.grey600,
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildQuestionItem(
    Map<String, dynamic> question,
    pw.Font font,
  ) {
    final isCorrect = question['isCorrect'] as bool;
    final isUnanswered = question['isUnanswered'] as bool;
    final statusColor =
        isCorrect
            ? PdfColors.green
            : (isUnanswered ? PdfColors.orange : PdfColors.red);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: statusColor.shade(0.1),
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: statusColor, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 20,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: statusColor,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '${question['questionNumber']}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Text(
                  question['question'] as String,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Your Answer: ${question['userAnswer']}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: statusColor,
                  ),
                ),
              ),
              if (!isCorrect)
                pw.Expanded(
                  child: pw.Text(
                    'Correct: ${question['correctAnswer']}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColors.green,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildImprovementSuggestions(
    List<Map<String, dynamic>> improvements,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Improvement Suggestions',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...improvements.map(
            (improvement) => _buildImprovementItem(improvement, font),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildImprovementItem(
    Map<String, dynamic> improvement,
    pw.Font font,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            improvement['title'] as String,
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            improvement['description'] as String,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}
