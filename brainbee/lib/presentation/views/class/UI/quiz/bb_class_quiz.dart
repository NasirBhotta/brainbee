// screens/quiz_list_screen.dart
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';

enum QuizStatus { notStarted, inProgress, overdue, submitted }

enum QuestionType { mcq, shortAnswer, longAnswer }

class Quiz {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime dueTime;
  final DateTime? extendedDueTime;
  final QuizStatus status;
  final bool isPublished;
  final bool isReopened;
  final List<Question> questions;
  final DateTime? submissionTime;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.dueTime,
    this.extendedDueTime,
    required this.status,
    required this.isPublished,
    this.isReopened = false,
    required this.questions,
    this.submissionTime,
  });

  DateTime get effectiveDueTime => extendedDueTime ?? dueTime;

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(effectiveDueTime);
  }
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String>? options;
  final bool? isMultiSelect;
  final String? answer;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.isMultiSelect,
    this.answer,
  });
}

class QuizListScreen extends StatefulWidget {
  final String classId;
  final String className;

  const QuizListScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List<Quiz> quizzes = [];
  bool isLoading = true;
  String? error;
  bool isDownloading = false;
  bool isUploading = false;
  String? uploadedFileName;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Simulate API call - replace with actual implementation
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API call
      quizzes = _getMockQuizzes();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  List<Quiz> _getMockQuizzes() {
    final now = DateTime.now();
    return [
      Quiz(
        id: '1',
        title: 'Chapter 1: Algebra Basics',
        description:
            'Test your understanding of algebraic expressions and equations',
        startTime: now.subtract(const Duration(hours: 1)),
        dueTime: now.add(const Duration(hours: 2)),
        status: QuizStatus.notStarted,
        isPublished: true,
        questions: [
          Question(
            id: '1',
            text: 'What is 2x + 3 = 7?',
            type: QuestionType.mcq,
            options: ['x = 1', 'x = 2', 'x = 3', 'x = 4'],
            isMultiSelect: false,
          ),
        ],
      ),
      Quiz(
        id: '2',
        title: 'Geometry Quiz',
        description: 'Questions on triangles and circles',
        startTime: now.subtract(const Duration(days: 1)),
        dueTime: now.subtract(const Duration(hours: 1)),
        status: QuizStatus.overdue,
        isPublished: true,
        questions: [
          Question(
            id: '1',
            text: 'Explain the properties of an equilateral triangle.',
            type: QuestionType.longAnswer,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quizzes',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: BBColors.white),
        ),
        backgroundColor: BBColors.secondaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BBColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
        ),
      );
    }

    if (error != null) {
      return _buildErrorState();
    }

    if (quizzes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadQuizzes,
      color: BBColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          return _buildQuizCard(quizzes[index]);
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
            'Failed to load quizzes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Unknown error occurred',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadQuizzes,
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
              foregroundColor: BBColors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.quiz_outlined,
            size: 64,
            color: BBColors.disabledText,
          ),
          const SizedBox(height: 16),
          Text(
            'No quizzes available at this time.',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: BBColors.disabledText),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openQuiz(quiz),
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
                      quiz.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _buildStatusBadge(quiz.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quiz.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: BBColors.bodyText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${_formatDateTime(quiz.effectiveDueTime)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
                  ),
                ],
              ),
              if (quiz.submissionTime != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: BBColors.successGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Submitted: ${_formatDateTime(quiz.submissionTime!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BBColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(QuizStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case QuizStatus.notStarted:
        backgroundColor = BBColors.primaryBlue;
        textColor = BBColors.white;
        text = 'Not Started';
        break;
      case QuizStatus.inProgress:
        backgroundColor = BBColors.orangeAccent;
        textColor = BBColors.white;
        text = 'In Progress';
        break;
      case QuizStatus.overdue:
        backgroundColor = BBColors.alertRed;
        textColor = BBColors.white;
        text = 'Overdue';
        break;
      case QuizStatus.submitted:
        backgroundColor = BBColors.successGreen;
        textColor = BBColors.white;
        text = 'Submitted';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _downloadQuestionSheet() async {
    setState(() {
      isDownloading = true;
      error = null;
    });

    try {
      // Simulate download process
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, you would:
      // 1. Make API call to get download URL
      // 2. Use url_launcher or similar to download file
      // 3. Handle file saving to device

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question sheet downloaded successfully'),
          backgroundColor: BBColors.successGreen,
        ),
      );
    } catch (e) {
      setState(() {
        error = 'Failed to download question sheet. Please try again.';
      });
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> _uploadCompletedSheet(Quiz quiz) async {
    // Check if current time is past due time
    if (DateTime.now().isAfter(quiz.effectiveDueTime)) {
      setState(() {
        error = 'Upload deadline has passed. Cannot submit answers.';
      });
      return;
    }

    setState(() {
      isUploading = true;
      error = null;
    });

    try {
      // Simulate file picker and upload process
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, you would:
      // 1. Use file_picker to select file
      // 2. Validate file format matches template
      // 3. Upload file to server
      // 4. Record submission timestamp

      final fileName = 'quiz_${quiz.id}_completed.pdf';
      final submissionTime = DateTime.now();

      setState(() {
        uploadedFileName = fileName;
      });

      // Navigate to submission confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => QuizSubmissionScreen(
                quiz: quiz,
                submissionTime: submissionTime,
                uploadedFileName: fileName,
              ),
        ),
      );
    } catch (e) {
      setState(() {
        error = 'Failed to upload file. Please try again.';
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _openQuiz(Quiz quiz) {
    if (!quiz.isActive && quiz.status != QuizStatus.submitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz is not available at this time'),
          backgroundColor: BBColors.alertRed,
        ),
      );
      return;
    }

    // Check if quiz contains only MCQ questions
    bool hasOnlyMCQ = quiz.questions.every((q) => q.type == QuestionType.mcq);

    if (hasOnlyMCQ) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MCQQuizScreen(quiz: quiz)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DocumentQuizScreen(quiz: quiz)),
      );
    }
  }
}

// screens/quiz_submission_screen.dart
class QuizSubmissionScreen extends StatelessWidget {
  final Quiz quiz;
  final DateTime submissionTime;
  final Map<String, dynamic>? answers;
  final String? uploadedFileName;
  final bool isAutoSubmit;

  const QuizSubmissionScreen({
    super.key,
    required this.quiz,
    required this.submissionTime,
    this.answers,
    this.uploadedFileName,
    this.isAutoSubmit = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isMCQQuiz = answers != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Submission Confirmed',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: BBColors.white),
        ),
        backgroundColor: BBColors.successGreen,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: BBColors.white),
            onPressed:
                () => Navigator.of(context).popUntil(
                  (route) =>
                      route.settings.name == '/quiz_list' || route.isFirst,
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: BBColors.successGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: BBColors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              isAutoSubmit ? 'Auto-Submitted!' : 'Successfully Submitted!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: BBColors.successGreen,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isAutoSubmit) ...[
              Text(
                'Your quiz was automatically submitted when time expired.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoRow(context, 'Quiz', quiz.title, Icons.quiz),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'Submission Time',
                      _formatDateTime(submissionTime),
                      Icons.access_time,
                    ),
                    if (isMCQQuiz) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        'Answers Submitted',
                        '${answers!.length} questions answered',
                        Icons.assignment_turned_in,
                      ),
                    ] else if (uploadedFileName != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        'File Uploaded',
                        uploadedFileName!,
                        Icons.attach_file,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isMCQQuiz) ...[
              Text(
                'Your answers were submitted at ${_formatTime(submissionTime)} on ${_formatDate(submissionTime)}.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                'Your completed sheet was uploaded at ${_formatTime(submissionTime)} on ${_formatDate(submissionTime)}.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.of(context).popUntil(
                      (route) =>
                          route.settings.name == '/quiz_list' || route.isFirst,
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                  foregroundColor: BBColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Quizzes',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: BBColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: BBColors.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: BBColors.bodyText),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}

// screens/mcq_quiz_screen.dart
class MCQQuizScreen extends StatefulWidget {
  final Quiz quiz;

  const MCQQuizScreen({super.key, required this.quiz});

  @override
  State<MCQQuizScreen> createState() => _MCQQuizScreenState();
}

class _MCQQuizScreenState extends State<MCQQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  Map<String, dynamic> answers = {};
  bool isSubmitting = false;
  Duration remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _initializeTimer();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final dueTime = widget.quiz.effectiveDueTime;

    if (now.isBefore(dueTime)) {
      remainingTime = dueTime.difference(now);
    } else {
      remainingTime = Duration.zero;
    }
  }

  void _initializeTimer() {
    if (remainingTime.inSeconds > 0) {
      _timerController = AnimationController(
        duration: remainingTime,
        vsync: this,
      );

      _timerController.addListener(() {
        setState(() {
          final elapsed = remainingTime.inSeconds * _timerController.value;
          remainingTime = Duration(
            seconds: (remainingTime.inSeconds - elapsed).round(),
          );
        });
      });

      _timerController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _submitAnswers(autoSubmit: true);
        }
      });

      _timerController.forward();
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop =
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Exit Quiz?'),
                    content: const Text(
                      'Your progress will be lost if you exit now.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Exit'),
                      ),
                    ],
                  ),
            ) ??
            false;
        return shouldPop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.quiz.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: BBColors.white),
          ),
          backgroundColor: BBColors.secondaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: BBColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    remainingTime.inMinutes < 5
                        ? BBColors.alertRed
                        : BBColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDuration(remainingTime),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color:
                      remainingTime.inMinutes < 5
                          ? BBColors.white
                          : BBColors.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildSubmitButton(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.quiz.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
          ),
          const SizedBox(height: 24),
          ...widget.quiz.questions.asMap().entries.map((entry) {
            int index = entry.key;
            Question question = entry.value;
            return _buildQuestionCard(question, index);
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${index + 1}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: BBColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(question.text, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (question.options != null) ...[
              if (question.isMultiSelect == true)
                ..._buildMultiSelectOptions(question)
              else
                ..._buildSingleSelectOptions(question),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSingleSelectOptions(Question question) {
    return question.options!.map((option) {
      bool isSelected = answers[question.id] == option;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            setState(() {
              answers[question.id] = option;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? BBColors.primaryColor : BBColors.borderGray,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? BBColors.primaryColor.withOpacity(0.1) : null,
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: option,
                  groupValue: answers[question.id],
                  onChanged: (value) {
                    setState(() {
                      answers[question.id] = value;
                    });
                  },
                  activeColor: BBColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : () => _submitAnswers(),
        style: ElevatedButton.styleFrom(
          backgroundColor: BBColors.primaryColor,
          foregroundColor: BBColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            isSubmitting
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(BBColors.white),
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  'Submit Answers',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: BBColors.white),
                ),
      ),
    );
  }

  Future<void> _submitAnswers({bool autoSubmit = false}) async {
    if (isSubmitting) return;

    // Check if time has expired and not auto-submit
    if (!autoSubmit && remainingTime.inSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time has expired. Cannot submit answers.'),
          backgroundColor: BBColors.alertRed,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _timerController.stop();

      // Show confirmation
      final submissionTime = DateTime.now();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => QuizSubmissionScreen(
                quiz: widget.quiz,
                submissionTime: submissionTime,
                answers: answers,
                isAutoSubmit: autoSubmit,
              ),
        ),
      );
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to submit answers. Please try again.'),
          backgroundColor: BBColors.alertRed,
          action: SnackBarAction(
            label: 'Retry',
            textColor: BBColors.white,
            onPressed: () => _submitAnswers(),
          ),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  List<Widget> _buildMultiSelectOptions(Question question) {
    List<String> selectedOptions = List<String>.from(
      answers[question.id] ?? [],
    );

    return question.options!.map((option) {
      bool isSelected = selectedOptions.contains(option);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            setState(() {
              List<String> current = List<String>.from(selectedOptions);
              if (isSelected) {
                current.remove(option);
              } else {
                current.add(option);
              }
              answers[question.id] = current;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? BBColors.primaryColor : BBColors.borderGray,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? BBColors.primaryColor.withOpacity(0.1) : null,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      List<String> current = List<String>.from(selectedOptions);
                      if (value == true) {
                        current.add(option);
                      } else {
                        current.remove(option);
                      }
                      answers[question.id] = current;
                    });
                  },
                  activeColor: BBColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

// screens/document_quiz_screen.dart
class DocumentQuizScreen extends StatefulWidget {
  final Quiz quiz;

  const DocumentQuizScreen({super.key, required this.quiz});

  @override
  State<DocumentQuizScreen> createState() => _DocumentQuizScreenState();
}

class _DocumentQuizScreenState extends State<DocumentQuizScreen> {
  bool isDownloading = false;
  bool isUploading = false;
  String? uploadedFileName;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quiz.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: BBColors.white),
        ),
        backgroundColor: BBColors.secondaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BBColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: BBColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.quiz.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: BBColors.bodyText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${_formatDateTime(widget.quiz.effectiveDueTime)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: BBColors.bodyText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionStep('1', 'Download the question sheet'),
                    _buildInstructionStep('2', 'Complete your answers offline'),
                    _buildInstructionStep(
                      '3',
                      'Upload the completed sheet before the deadline',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDownloadSection(),
            const SizedBox(height: 24),
            _buildUploadSection(),
            if (error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BBColors.alertRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BBColors.alertRed),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: BBColors.alertRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.alertRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: BBColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: BBColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.download,
                  color: BBColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Step 1: Download Question Sheet',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Download the question template to complete your answers offline.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isDownloading ? null : _downloadQuestionSheet,
                icon:
                    isDownloading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              BBColors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.download),
                label: Text(
                  isDownloading ? 'Downloading...' : 'Download Question Sheet',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryBlue,
                  foregroundColor: BBColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.upload,
                  color: BBColors.successGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Step 3: Upload Completed Sheet',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your completed answer sheet before the deadline.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            ),
            if (uploadedFileName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BBColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BBColors.successGreen),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: BBColors.successGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Uploaded: $uploadedFileName',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : _uploadCompletedSheet,
                icon:
                    isUploading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              BBColors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.upload),
                label: Text(
                  isUploading ? 'Uploading...' : 'Upload Completed Sheet',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.successGreen,
                  foregroundColor: BBColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadQuestionSheet() async {
    setState(() {
      isDownloading = true;
      error = null;
    });

    try {
      // Simulate download process
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, you would:
      // 1. Make API call to get download URL
      // 2. Use url_launcher or similar to download file
      // 3. Handle file saving to device

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question sheet downloaded successfully'),
          backgroundColor: BBColors.successGreen,
        ),
      );
    } catch (e) {
      setState(() {
        error = 'Failed to download question sheet. Please try again.';
      });
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> _uploadCompletedSheet() async {
    // Check if current time is past due time
    if (DateTime.now().isAfter(widget.quiz.effectiveDueTime)) {
      setState(() {
        error = 'Upload deadline has passed. Cannot submit answers.';
      });
      return;
    }

    setState(() {
      isUploading = true;
      error = null;
    });

    try {
      // Simulate file picker and upload process
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, you would:
      // 1. Use file_picker to select file
      // 2. Validate file format matches template
      // 3. Upload file to server
      // 4. Record submission timestamp

      final fileName = 'quiz_${widget.quiz.id}_completed.pdf';
      final submissionTime = DateTime.now();

      setState(() {
        uploadedFileName = fileName;
      });

      // Navigate to submission confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => QuizSubmissionScreen(
                quiz: widget.quiz,
                submissionTime: submissionTime,
                uploadedFileName: fileName,
              ),
        ),
      );
    } catch (e) {
      setState(() {
        error = 'Failed to upload file. Please try again.';
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Usage in your main class detail screen:
// Add this to your Actions section in the class detail screen

class QuizAction extends StatelessWidget {
  final String classId;
  final String className;

  const QuizAction({super.key, required this.classId, required this.className});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: BBColors.violetAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.quiz, color: BBColors.violetAccent, size: 24),
      ),
      title: Text('Quizzes', style: Theme.of(context).textTheme.titleSmall),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: BBColors.bodyText,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    QuizListScreen(classId: classId, className: className),
            settings: const RouteSettings(name: '/quiz_list'),
          ),
        );
      },
    );
  }
}
