import 'package:brainbee/presentation/views/class/bloc/quiz/bloc/quiz_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/bb_question.dart';
import 'package:brainbee/presentation/views/class/models/quiz_model.dart';

class QuizListScreen extends StatelessWidget {
  final String classId;
  final String className;

  const QuizListScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return _QuizListView(classId: classId, className: className);
  }
}

class _QuizListView extends StatefulWidget {
  final String classId;
  final String className;

  const _QuizListView({required this.classId, required this.className});

  @override
  State<_QuizListView> createState() => _QuizListViewState();
}

class _QuizListViewState extends State<_QuizListView> {
  @override
  void initState() {
    super.initState();
    context.read<ClassQuizBloc>().add(
      FetchQuizzesEvent(classId: widget.classId),
    );
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
      body: BlocBuilder<ClassQuizBloc, ClassQuizState>(
        builder: (context, state) {
          if (state is QuizLoading) return _buildLoading();
          if (state is QuizError) return _buildError(context, state);
          if (state is QuizEmpty) return _buildEmpty(context);
          if (state is QuizListLoaded) return _buildList(context, state);
          return const SizedBox.shrink();
        },
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

  Widget _buildError(BuildContext context, QuizError state) {
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
            'Failed to load quizzes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () => context.read<ClassQuizBloc>().add(
                  FetchQuizzesEvent(classId: widget.classId),
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

  Widget _buildEmpty(BuildContext context) {
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
            'No quizzes available',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: BBColors.disabledText),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, QuizListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ClassQuizBloc>().add(
          RefreshQuizzesEvent(classId: widget.classId),
        );
        await context.read<ClassQuizBloc>().stream.firstWhere(
          (s) => s is! QuizLoading,
        );
      },
      color: BBColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.quizzes.length,
        itemBuilder:
            (context, index) => _buildQuizCard(context, state.quizzes[index]),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, ClassQuiz quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openQuiz(context, quiz),
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
                  _buildStatusBadge(context, quiz.status),
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

  Widget _buildStatusBadge(BuildContext context, QuizStatus status) {
    Color bg, textColor;
    String text;
    switch (status) {
      case QuizStatus.notStarted:
        bg = BBColors.primaryBlue;
        textColor = BBColors.white;
        text = 'Not Started';
        break;
      case QuizStatus.inProgress:
        bg = BBColors.orangeAccent;
        textColor = BBColors.white;
        text = 'In Progress';
        break;
      case QuizStatus.overdue:
        bg = BBColors.alertRed;
        textColor = BBColors.white;
        text = 'Overdue';
        break;
      case QuizStatus.submitted:
        bg = BBColors.successGreen;
        textColor = BBColors.white;
        text = 'Submitted';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
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

  void _openQuiz(BuildContext context, ClassQuiz quiz) {
    if (!quiz.isActive && quiz.status != QuizStatus.submitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz is not available at this time'),
          backgroundColor: BBColors.alertRed,
        ),
      );
      return;
    }
    bool hasOnlyMCQ = quiz.questions.every((q) => q.type == QuestionType.mcq);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (ctx) => BlocProvider.value(
              value: context.read<ClassQuizBloc>(),
              child:
                  hasOnlyMCQ
                      ? MCQQuizScreen(quiz: quiz)
                      : DocumentQuizScreen(quiz: quiz),
            ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================
// MCQ Quiz Screen
// ============================================
class MCQQuizScreen extends StatefulWidget {
  final ClassQuiz quiz;
  const MCQQuizScreen({super.key, required this.quiz});

  @override
  State<MCQQuizScreen> createState() => _MCQQuizScreenState();
}

class _MCQQuizScreenState extends State<MCQQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  Map<String, dynamic> answers = {}; // questionId -> selected option index
  Duration remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _initializeTimer();
    context.read<ClassQuizBloc>().add(StartQuizEvent(quiz: widget.quiz));
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final dueTime = widget.quiz.effectiveDueTime;
    remainingTime =
        now.isBefore(dueTime) ? dueTime.difference(now) : Duration.zero;
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
        if (status == AnimationStatus.completed) _submitQuiz(autoSubmit: true);
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
        return await showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Exit Quiz?'),
                    content: const Text(
                      'Your progress will be lost if you exit now.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Exit'),
                      ),
                    ],
                  ),
            ) ??
            false;
      },
      child: BlocListener<ClassQuizBloc, ClassQuizState>(
        listener: (context, state) {
          if (state is QuizSubmitSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (ctx) => QuizSubmissionScreen(
                      quiz: widget.quiz,
                      submittedAt: state.submittedAt,
                      answers: state.answers,
                      isAutoSubmit: state.isAutoSubmit,
                    ),
              ),
            );
          }
          if (state is QuizSubmitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: BBColors.alertRed,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: BBColors.white,
                  onPressed: () => _submitQuiz(),
                ),
              ),
            );
          }
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
          body: SingleChildScrollView(
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
                ...widget.quiz.questions.asMap().entries.map(
                  (entry) => _buildQuestionCard(entry.value, entry.key),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildSubmitButton(),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, int index) {
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
            ...question.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final optionText = entry.value;

              // Check if this option is selected
              final selectedAnswer = answers[question.id];
              final isSelected = selectedAnswer == optionIndex;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      // Store the option INDEX, not the text
                      answers[question.id] = optionIndex;
                    });

                    // Update bloc
                    context.read<ClassQuizBloc>().add(
                      UpdateAnswerEvent(
                        questionId: question.id,
                        answer: optionIndex,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected
                                ? BBColors.primaryColor
                                : BBColors.borderGray,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color:
                          isSelected
                              ? BBColors.primaryColor.withOpacity(0.1)
                              : null,
                    ),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: optionIndex,
                          groupValue: answers[question.id],
                          onChanged: (_) {},
                          activeColor: BBColors.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            optionText,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _submitQuiz({bool autoSubmit = false}) {
    if (remainingTime.inSeconds <= 0 && !autoSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time has expired'),
          backgroundColor: BBColors.alertRed,
        ),
      );
      return;
    }

    // Show confirmation dialog unless auto-submit
    if (!autoSubmit) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Submit Quiz?'),
              content: Text(
                'You have answered ${answers.length} out of ${widget.quiz.questions.length} questions.\n\nAre you sure you want to submit?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _performSubmit(autoSubmit);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BBColors.primaryColor,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
      );
    } else {
      _performSubmit(autoSubmit);
    }
  }

  void _performSubmit(bool autoSubmit) {
    _timerController.stop();

    context.read<ClassQuizBloc>().add(
      SubmitQuizEvent(
        quizId: widget.quiz.id,
        answers: answers,
        isAutoSubmit: autoSubmit,
      ),
    );
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ClassQuizBloc, ClassQuizState>(
      builder: (context, state) {
        final isSubmitting = state is QuizInProgress && state.isSubmitting;
        return Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: isSubmitting ? null : () => _submitQuiz(),
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          BBColors.white,
                        ),
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
      },
    );
  }
}

// ============================================
// Document Quiz Screen
// ============================================
class DocumentQuizScreen extends StatelessWidget {
  final ClassQuiz quiz;
  const DocumentQuizScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClassQuizBloc, ClassQuizState>(
      listener: (context, state) {
        if (state is QuizSheetDownloadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Question sheet downloaded'),
              backgroundColor: BBColors.successGreen,
            ),
          );
        }
        if (state is QuizSheetDownloadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: BBColors.alertRed,
            ),
          );
        }
        if (state is QuizSheetUploadSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (ctx) => QuizSubmissionScreen(
                    quiz: quiz,
                    submittedAt: state.uploadedAt,
                    uploadedFileName: 'Completed Sheet',
                  ),
            ),
          );
        }
        if (state is QuizSheetUploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: BBColors.alertRed,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            quiz.title,
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
        body: BlocBuilder<ClassQuizBloc, ClassQuizState>(
          builder: (context, state) {
            final isDownloading = state is QuizSheetDownloading;
            final isUploading = state is QuizSheetUploading;
            return SingleChildScrollView(
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: BBColors.primaryColor),
                          ),
                          const SizedBox(height: 12),
                          Text(quiz.description),
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
                                'Due: ${_formatDateTime(quiz.effectiveDueTime)}',
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
                  _buildDownloadSection(context, isDownloading),
                  const SizedBox(height: 24),
                  _buildUploadSection(context, isUploading),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDownloadSection(BuildContext context, bool isDownloading) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.download, color: BBColors.primaryBlue, size: 20),
                SizedBox(width: 8),
                Text('Step 1: Download Question Sheet'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isDownloading
                        ? null
                        : () => context.read<ClassQuizBloc>().add(
                          DownloadQuizSheetEvent(quiz: quiz),
                        ),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context, bool isUploading) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.upload, color: BBColors.successGreen, size: 20),
                SizedBox(width: 8),
                Text('Step 2: Upload Completed Sheet'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : () => _uploadSheet(context),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadSheet(BuildContext context) async {
    if (DateTime.now().isAfter(quiz.effectiveDueTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload deadline has passed'),
          backgroundColor: BBColors.alertRed,
        ),
      );
      return;
    }
    // In real impl, use file_picker
    context.read<ClassQuizBloc>().add(
      UploadQuizSheetEvent(quizId: quiz.id, filePath: '/mock/path.pdf'),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================
// Quiz Submission Screen
// ============================================
class QuizSubmissionScreen extends StatelessWidget {
  final ClassQuiz quiz;
  final DateTime submittedAt;
  final Map<String, dynamic>? answers;
  final String? uploadedFileName;
  final bool isAutoSubmit;

  const QuizSubmissionScreen({
    super.key,
    required this.quiz,
    required this.submittedAt,
    this.answers,
    this.uploadedFileName,
    this.isAutoSubmit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Submission Confirmed',
          style: TextStyle(color: BBColors.white),
        ),
        backgroundColor: BBColors.successGreen,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: BBColors.white),
            onPressed:
                () => Navigator.of(context).popUntil((route) => route.isFirst),
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
            if (isAutoSubmit) ...[
              const SizedBox(height: 16),
              Text(
                'Your quiz was automatically submitted when time expired.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
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
                      _formatDateTime(submittedAt),
                      Icons.access_time,
                    ),
                    if (answers != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        'Answers Submitted',
                        '${answers!.length} questions',
                        Icons.assignment_turned_in,
                      ),
                    ],
                    if (uploadedFileName != null) ...[
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
