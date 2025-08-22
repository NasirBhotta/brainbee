// screens/class_materials_screen.dart
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';

// models/material_models.dart
class ClassMaterial {
  final String id;
  final String name;
  final String type; // 'pdf', 'doc', 'video', 'image', 'ppt'
  final String url;
  final int size; // in bytes
  final DateTime uploadedDate;
  final String uploadedBy;
  final String? description;

  ClassMaterial({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.size,
    required this.uploadedDate,
    required this.uploadedBy,
    this.description,
  });

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'video':
      case 'mp4':
      case 'avi':
        return Icons.video_file;
      case 'image':
      case 'jpg':
      case 'png':
        return Icons.image;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color get typeColor {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'video':
      case 'mp4':
      case 'avi':
        return Colors.purple;
      case 'image':
      case 'jpg':
      case 'png':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class ClassMaterialsScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String teacherName;

  const ClassMaterialsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.teacherName,
  });

  @override
  State<ClassMaterialsScreen> createState() => _ClassMaterialsScreenState();
}

class _ClassMaterialsScreenState extends State<ClassMaterialsScreen> {
  bool _isLoading = false;
  bool _hasError = false;
  List<ClassMaterial> _materials = [];
  final Map<String, double> _downloadProgress = {};
  final Set<String> _downloadingItems = {};

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - only teacher-uploaded materials
      _materials = [
        ClassMaterial(
          id: '1',
          name: 'Chapter 3 - Algebra Basics.pdf',
          type: 'pdf',
          url: 'https://example.com/algebra-basics.pdf',
          size: 2048576, // 2MB
          uploadedDate: DateTime.now().subtract(const Duration(days: 2)),
          uploadedBy: widget.teacherName,
          description: 'Essential algebra concepts and formulas',
        ),
        ClassMaterial(
          id: '2',
          name: 'Homework Assignment 5.docx',
          type: 'doc',
          url: 'https://example.com/homework-5.docx',
          size: 512000, // 500KB
          uploadedDate: DateTime.now().subtract(const Duration(days: 1)),
          uploadedBy: widget.teacherName,
          description: 'Due Friday - Quadratic Equations',
        ),
        ClassMaterial(
          id: '3',
          name: 'Lecture Video - Linear Functions.mp4',
          type: 'video',
          url: 'https://example.com/linear-functions.mp4',
          size: 52428800, // 50MB
          uploadedDate: DateTime.now().subtract(const Duration(hours: 12)),
          uploadedBy: widget.teacherName,
          description: 'Complete lecture on linear functions',
        ),
        ClassMaterial(
          id: '4',
          name: 'Formula Sheet.png',
          type: 'image',
          url: 'https://example.com/formula-sheet.png',
          size: 1024000, // 1MB
          uploadedDate: DateTime.now().subtract(const Duration(hours: 6)),
          uploadedBy: widget.teacherName,
          description: 'Quick reference for all formulas',
        ),
        ClassMaterial(
          id: '5',
          name: 'Midterm Preparation.pptx',
          type: 'ppt',
          url: 'https://example.com/midterm-prep.pptx',
          size: 5242880, // 5MB
          uploadedDate: DateTime.now().subtract(const Duration(hours: 3)),
          uploadedBy: widget.teacherName,
          description: 'Study guide for upcoming midterm',
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _downloadMaterial(ClassMaterial material) async {
    // Show download confirmation dialog
    final shouldDownload = await _showDownloadConfirmationDialog(material);
    if (!shouldDownload) return;

    setState(() {
      _downloadingItems.add(material.id);
      _downloadProgress[material.id] = 0.0;
    });

    try {
      // Simulate download progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _downloadProgress[material.id] = i / 100.0;
        });
      }

      // Simulate random failure (20% chance)
      if (DateTime.now().millisecond % 5 == 0) {
        throw Exception('Download failed');
      }

      // Download successful
      setState(() {
        _downloadingItems.remove(material.id);
        _downloadProgress.remove(material.id);
      });

      _showDownloadSuccessDialog(material);
    } catch (e) {
      setState(() {
        _downloadingItems.remove(material.id);
        _downloadProgress.remove(material.id);
      });

      _showDownloadErrorDialog(material);
    }
  }

  Future<bool> _showDownloadConfirmationDialog(ClassMaterial material) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(
                      Icons.download,
                      color: BBColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Download Material',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: BBColors.darkHeading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Do you want to download this file?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BBColors.bodyText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BBColors.lightGrayBG,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: BBColors.borderGray),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                material.typeIcon,
                                color: material.typeColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  material.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall?.copyWith(
                                    color: BBColors.darkHeading,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Size: ${material.formattedSize}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: BBColors.bodyText),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Type: ${material.type.toUpperCase()}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: BBColors.bodyText),
                              ),
                            ],
                          ),
                          if (material.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              material.description!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: BBColors.bodyText,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: BBColors.disabledText),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BBColors.primaryColor,
                    ),
                    child: const Text('Download'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showDownloadSuccessDialog(ClassMaterial material) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: BBColors.successGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Download Complete',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              '${material.name} has been downloaded successfully.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.successGreen,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showDownloadErrorDialog(ClassMaterial material) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error, color: BBColors.alertRed, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Download Failed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              'Failed to download ${material.name}. Please check your connection and try again.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: BBColors.disabledText),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _downloadMaterial(material);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.alertRed,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
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
              'Class Materials',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMaterials,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
        ),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_materials.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadMaterials,
      color: BBColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _materials.length,
        itemBuilder: (context, index) {
          return _buildMaterialCard(_materials[index]);
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
            'Failed to load materials',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BBColors.darkHeading),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMaterials,
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
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
          const Icon(Icons.folder_open, size: 64, color: BBColors.disabledText),
          const SizedBox(height: 16),
          Text(
            'No materials available',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BBColors.darkHeading),
          ),
          const SizedBox(height: 8),
          Text(
            'No materials available at this time.\nYour teacher will upload resources here.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMaterials,
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(ClassMaterial material) {
    final isDownloading = _downloadingItems.contains(material.id);
    final progress = _downloadProgress[material.id] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isDownloading ? null : () => _downloadMaterial(material),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: material.typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      material.typeIcon,
                      color: material.typeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: BBColors.darkHeading,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              material.formattedSize,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: BBColors.bodyText),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: material.typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                material.type.toUpperCase(),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: material.typeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isDownloading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          BBColors.primaryColor,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.download,
                      color: BBColors.primaryColor,
                      size: 24,
                    ),
                ],
              ),
              if (material.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  material.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BBColors.bodyText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: BBColors.bodyText),
                  const SizedBox(width: 4),
                  Text(
                    'Uploaded by ${material.uploadedBy}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: BBColors.bodyText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(material.uploadedDate),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
                  ),
                ],
              ),
              if (isDownloading) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: BBColors.borderGray,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    BBColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Downloading... ${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BBColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
