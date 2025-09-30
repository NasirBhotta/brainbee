import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/flashcard_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BBFlashCardsScreenNew extends StatefulWidget {
  final List<Flashcard> flashcards;
  final int initialIndex;

  const BBFlashCardsScreenNew({
    super.key,
    required this.flashcards,
    this.initialIndex = 0,
  });

  @override
  State<BBFlashCardsScreenNew> createState() => _BBFlashCardsScreenNewState();
}

class _BBFlashCardsScreenNewState extends State<BBFlashCardsScreenNew>
    with TickerProviderStateMixin {
  int currentCardIndex = 0;
  bool isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late List<Flashcard> localFlashcards; // Use a local copy for shuffling

  @override
  void initState() {
    super.initState();
    localFlashcards = List.from(widget.flashcards);
    currentCardIndex = widget.initialIndex;

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  void _nextCard() {
    if (currentCardIndex < localFlashcards.length - 1) {
      setState(() {
        currentCardIndex++;
        isFlipped = false;
      });
      _flipController.reset();
    }
  }

  void _previousCard() {
    if (currentCardIndex > 0) {
      setState(() {
        currentCardIndex--;
        isFlipped = false;
      });
      _flipController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (localFlashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("No flashcards available.")),
      );
    }

    return Scaffold(
      backgroundColor: BBColors.white,
      appBar: AppBar(
        backgroundColor: BBColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: BBColors.darkHeading),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI FlashCards',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: BBColors.darkHeading,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: BBColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${currentCardIndex + 1}/${localFlashcards.length}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: BBColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            margin: const EdgeInsets.all(20),
            child: LinearProgressIndicator(
              value: (currentCardIndex + 1) / localFlashcards.length,
              backgroundColor: BBColors.primaryColor.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                BBColors.primaryColor,
              ),
              minHeight: 6,
            ),
          ),

          // Flashcard
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final isShowingFront = _flipAnimation.value < 0.5;
                    return Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_flipAnimation.value * 3.14159),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient:
                              isShowingFront
                                  ? LinearGradient(
                                    colors: [
                                      BBColors.primaryColor,
                                      BBColors.primaryColor.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : LinearGradient(
                                    colors: [
                                      Colors.teal,
                                      Colors.teal.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          boxShadow: [
                            BoxShadow(
                              color: (isShowingFront
                                      ? BBColors.primaryColor
                                      : Colors.teal)
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isShowingFront
                                    ? Icons.help_outline
                                    : Icons.lightbulb_outline,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                isShowingFront ? 'Question' : 'Answer',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isShowingFront
                                    ? localFlashcards[currentCardIndex].front
                                    : localFlashcards[currentCardIndex].back,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isShowingFront
                                      ? 'Tap to reveal answer'
                                      : 'Tap to see question',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Navigation controls
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                Container(
                  decoration: BoxDecoration(
                    color:
                        currentCardIndex > 0
                            ? BBColors.primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: currentCardIndex > 0 ? _previousCard : null,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color:
                          currentCardIndex > 0
                              ? BBColors.primaryColor
                              : Colors.grey,
                    ),
                  ),
                ),

                // Flip button
                Container(
                  decoration: BoxDecoration(
                    color: BBColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _flipCard,
                    icon: const Icon(Icons.flip, color: Colors.white),
                  ),
                ),

                // Next button
                Container(
                  decoration: BoxDecoration(
                    color:
                        currentCardIndex < localFlashcards.length - 1
                            ? BBColors.primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed:
                        currentCardIndex < localFlashcards.length - 1
                            ? _nextCard
                            : null,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color:
                          currentCardIndex < localFlashcards.length - 1
                              ? BBColors.primaryColor
                              : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: BBColors.primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Reset and start over
                        setState(() {
                          localFlashcards = List.from(widget.flashcards);
                          currentCardIndex = 0;
                          isFlipped = false;
                        });
                        _flipController.reset();
                      },
                      child: Text(
                        'Start Over',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: BBColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: BBColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Shuffle cards functionality
                        setState(() {
                          localFlashcards.shuffle();
                          currentCardIndex = 0;
                          isFlipped = false;
                        });
                        _flipController.reset();
                      },
                      child: Text(
                        'Shuffle',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
