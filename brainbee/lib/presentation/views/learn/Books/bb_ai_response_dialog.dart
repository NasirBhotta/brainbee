import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:google_fonts/google_fonts.dart';

// Replace your _showResultDialog method with this improved version
class ImprovedAIResponseDialog extends StatelessWidget {
  final String title;
  final String content;

  const ImprovedAIResponseDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: BBColors.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BBColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: BBColors.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FormattedAIResponse(content: content),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: BBColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Got it',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to parse and format AI response
class FormattedAIResponse extends StatelessWidget {
  final String content;

  const FormattedAIResponse({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final sections = _parseContent(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) => _buildSection(section)).toList(),
    );
  }

  List<ContentSection> _parseContent(String text) {
    final sections = <ContentSection>[];
    final lines = text.split('\n');

    ContentSection? currentSection;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Check for bold headers (wrapped in **)
      if (line.startsWith('**') && line.endsWith('**')) {
        // Save previous section
        if (currentSection != null) {
          sections.add(currentSection);
        }

        // Create new section
        currentSection = ContentSection(
          title: line.replaceAll('**', '').trim(),
          items: [],
        );
      }
      // Check for numbered list items (1., 2., etc.)
      else if (RegExp(r'^\d+\.').hasMatch(line)) {
        currentSection?.items.add(
          ContentItem(
            text: line.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
            isNumbered: true,
          ),
        );
      }
      // Check for bullet points (-, *, •)
      else if (line.startsWith('-') ||
          line.startsWith('*') ||
          line.startsWith('•')) {
        currentSection?.items.add(
          ContentItem(text: line.substring(1).trim(), isBullet: true),
        );
      }
      // Regular text
      else {
        if (currentSection != null) {
          currentSection.items.add(ContentItem(text: line));
        } else {
          // Create a section without title for standalone text
          sections.add(
            ContentSection(title: '', items: [ContentItem(text: line)]),
          );
        }
      }
    }

    // Add last section
    if (currentSection != null) {
      sections.add(currentSection);
    }

    return sections;
  }

  Widget _buildSection(ContentSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          if (section.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                section.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: BBColors.primaryColor,
                  height: 1.4,
                ),
              ),
            ),

          // Section items
          ...section.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildContentItem(item, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildContentItem(ContentItem item, int index) {
    Widget content;

    if (item.isNumbered) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. ',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: BBColors.primaryColor,
              height: 1.6,
            ),
          ),
          Expanded(
            child: Text(
              _parseBoldText(item.text),
              style: GoogleFonts.poppins(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      );
    } else if (item.isBullet) {
      content = Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ',
              style: TextStyle(
                fontSize: 16,
                color: BBColors.primaryColor,
                height: 1.6,
              ),
            ),
            Expanded(
              child: Text(
                _parseBoldText(item.text),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      content = RichText(text: _buildFormattedText(item.text));
    }

    return Padding(padding: const EdgeInsets.only(bottom: 10), child: content);
  }

  String _parseBoldText(String text) {
    return text.replaceAll('**', '');
  }

  TextSpan _buildFormattedText(String text) {
    final parts = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in pattern.allMatches(text)) {
      // Add text before bold
      if (match.start > lastIndex) {
        parts.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: GoogleFonts.poppins(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        );
      }

      // Add bold text
      parts.add(
        TextSpan(
          text: match.group(1),
          style: GoogleFonts.poppins(
            fontSize: 16,
            height: 1.6,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      parts.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: GoogleFonts.poppins(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      );
    }

    return TextSpan(children: parts);
  }
}

// Data models
class ContentSection {
  final String title;
  final List<ContentItem> items;

  ContentSection({required this.title, required this.items});
}

class ContentItem {
  final String text;
  final bool isNumbered;
  final bool isBullet;

  ContentItem({
    required this.text,
    this.isNumbered = false,
    this.isBullet = false,
  });
}
