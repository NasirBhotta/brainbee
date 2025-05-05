import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/material_model.dart';
import '../services/material_service.dart';
import '../utils/helpers.dart';

class ClassMaterialsTab extends StatelessWidget {
  final String classId;

  const ClassMaterialsTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialService>(
      builder: (context, materialService, child) {
        final materials = mockMaterials.where((m) => m.classId == classId).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index];
            return Card(
              child: ListTile(
                leading: Icon(_getFileTypeIcon(material.fileType)),
                title: Text(material.title),
                subtitle: Text(
                  '${Helpers.formatFileSize(material.fileSize)} • ${Helpers.formatDate(material.uploadDate)}',
                ),
                trailing: IconButton(
                  icon: Icon(
                    material.isDownloaded ? Icons.check_circle : Icons.download,
                    color: material.isDownloaded ? Colors.green : null,
                  ),
                  onPressed: () {
                    // TODO: Implement download functionality
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }
}