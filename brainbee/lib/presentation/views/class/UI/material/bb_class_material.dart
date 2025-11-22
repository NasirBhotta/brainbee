import 'package:brainbee/presentation/views/class/bloc/material/bloc/classMaterial_bloc.dart';
import 'package:brainbee/presentation/views/class/models/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';

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
  @override
  void initState() {
    super.initState();

    context.read<ClassMaterialBloc>().add(
      FetchMaterialsEvent(classId: widget.classId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _MaterialsView(
      classId: widget.classId,
      className: widget.className,
      teacherName: widget.teacherName,
    );
  }
}

class _MaterialsView extends StatelessWidget {
  final String classId;
  final String className;
  final String teacherName;

  const _MaterialsView({
    required this.classId,
    required this.className,
    required this.teacherName,
  });

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
              className,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed:
                () => context.read<ClassMaterialBloc>().add(
                  RefreshMaterialsEvent(classId: classId),
                ),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ClassMaterialBloc, ClassMaterialState>(
            listenWhen: (prev, curr) => curr is MaterialDownloadSuccess,
            listener: (context, state) {
              if (state is MaterialDownloadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.material.name} downloaded'),
                    backgroundColor: BBColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          BlocListener<ClassMaterialBloc, ClassMaterialState>(
            listenWhen: (prev, curr) => curr is MaterialDownloadError,
            listener: (context, state) {
              if (state is MaterialDownloadError) {
                _showDownloadErrorDialog(
                  context,
                  state.material,
                  state.message,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ClassMaterialBloc, ClassMaterialState>(
          buildWhen:
              (prev, curr) =>
                  curr is! MaterialDownloadSuccess &&
                  curr is! MaterialDownloadError,
          builder: (context, state) {
            if (state is MaterialLoading) return _buildLoading();
            if (state is MaterialError) return _buildError(context, state);
            if (state is MaterialEmpty) return _buildEmpty(context);
            if (state is MaterialLoaded) return _buildList(context, state);
            return const SizedBox.shrink();
          },
        ),
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

  Widget _buildError(BuildContext context, MaterialError state) {
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
            state.isNetworkError
                ? 'No Internet Connection'
                : 'Failed to load materials',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BBColors.darkHeading),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () => context.read<ClassMaterialBloc>().add(
                  FetchMaterialsEvent(classId: classId),
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
            'Your teacher will upload resources here.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () => context.read<ClassMaterialBloc>().add(
                  RefreshMaterialsEvent(classId: classId),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, MaterialLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ClassMaterialBloc>().add(
          RefreshMaterialsEvent(classId: classId),
        );
        await context.read<ClassMaterialBloc>().stream.firstWhere(
          (s) => s is! MaterialLoading,
        );
      },
      color: BBColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.materials.length,
        itemBuilder:
            (context, index) =>
                _buildMaterialCard(context, state, state.materials[index]),
      ),
    );
  }

  Widget _buildMaterialCard(
    BuildContext context,
    MaterialLoaded state,
    ClassMaterial material,
  ) {
    final isDownloading = state.downloadingIds.contains(material.id);
    final progress = state.downloadProgress[material.id] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            isDownloading ? null : () => _showDownloadDialog(context, material),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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

  void _showDownloadDialog(BuildContext context, ClassMaterial material) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.download,
                  color: BBColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(child: Text('Download Material')),
              ],
            ),
            content: Text('Download ${material.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: BBColors.disabledText),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<ClassMaterialBloc>().add(
                    DownloadMaterialEvent(material: material),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                ),
                child: const Text('Download'),
              ),
            ],
          ),
    );
  }

  void _showDownloadErrorDialog(
    BuildContext context,
    ClassMaterial material,
    String message,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: BBColors.alertRed, size: 24),
                SizedBox(width: 8),
                Text('Download Failed'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: BBColors.disabledText),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<ClassMaterialBloc>().add(
                    DownloadMaterialEvent(material: material),
                  );
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

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }
}
