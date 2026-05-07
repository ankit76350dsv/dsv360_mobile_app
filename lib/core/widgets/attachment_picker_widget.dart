import 'dart:io';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dsv360/core/models/attachment.dart';

class AttachmentPickerWidget extends StatefulWidget {
  final Function(List<Attachment>) onAttachmentsSelected;
  final List<Attachment> initialAttachments;

  const AttachmentPickerWidget({
    super.key,
    required this.onAttachmentsSelected,
    this.initialAttachments = const [],
  });

  @override
  State<AttachmentPickerWidget> createState() => AttachmentPickerWidgetState();
}

class AttachmentPickerWidgetState extends State<AttachmentPickerWidget> {
  late List<Attachment> _selectedAttachments;

  @override
  void initState() {
    super.initState();
    _selectedAttachments = List.from(widget.initialAttachments);
  }

  // Public method to trigger file picker from outside
  Future<void> pickFiles() async {
    await _pickFiles();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'xlsx', 'xls', 'txt'],
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.path != null) {
            final attachment = Attachment(
              fileName: file.name,
              fileType: _getFileType(file.extension ?? ''),
              fileSize: file.size,
              localFile: File(file.path!),
            );
            _selectedAttachments.add(attachment);
            debugPrint('📎 File added: ${file.name} (${(file.size / 1024 / 1024).toStringAsFixed(2)} MB)');
          }
        }
        widget.onAttachmentsSelected(_selectedAttachments);
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error picking files: $e');
      
      showErrorSnackBar(context, 'Failed to pick files. Please try again.');
    }
  }

  String _getFileType(String extension) {
    extension = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) return 'image';
    if (extension == 'pdf') return 'pdf';
    if (['doc', 'docx'].contains(extension)) return 'document';
    if (['xlsx', 'xls'].contains(extension)) return 'spreadsheet';
    return 'document';
  }

  void _removeAttachment(int index) {
    setState(() {
      _selectedAttachments.removeAt(index);
      widget.onAttachmentsSelected(_selectedAttachments);
    });
    debugPrint('🗑️ Attachment removed');
  }

  IconData _getFileIcon(Attachment attachment) {
    if (attachment.isImage) return Icons.image;
    if (attachment.isPdf) return Icons.picture_as_pdf;
    if (attachment.isDocument) return Icons.description;
    return Icons.attachment;
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add attachment button
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: customColors.inputBorder!,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  color: customColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedAttachments.isEmpty
                        ? 'Add Attachments (PDF, Images, Documents)'
                        : '${_selectedAttachments.length} file(s) selected',
                    style: TextStyle(
                      color: _selectedAttachments.isEmpty
                          ? customColors.textSecondary
                          : customColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.add_circle_outline,
                  color: customColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Show selected attachments as list
        if (_selectedAttachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: customColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: customColors.inputBorder!,
                width: 1,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedAttachments.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: customColors.inputBorder,
              ),
              itemBuilder: (context, index) {
                final attachment = _selectedAttachments[index];
                final sizeMB =
                    (attachment.fileSize / 1024 / 1024).toStringAsFixed(2);

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        _getFileIcon(attachment),
                        color: customColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: customColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$sizeMB MB',
                              style: TextStyle(
                                color: customColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeAttachment(index),
                        icon: Icon(
                          Icons.close,
                          color: customColors.textSecondary,
                          size: 20,
                        ),
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
