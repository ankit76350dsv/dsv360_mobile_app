import 'dart:io';

class Attachment {
  final String? id; // For existing attachments from API
  final String fileName;
  final String fileType; // 'image', 'pdf', 'document', etc.
  final int fileSize; // in bytes
  final File? localFile; // For new attachments being uploaded
  final String? fileUrl; // For existing attachments from server

  Attachment({
    this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.localFile,
    this.fileUrl,
  });

  /// Check if this is a local file (not yet uploaded)
  bool get isLocal => localFile != null;

  /// Check if this is a file from server
  bool get isFromServer => fileUrl != null && !isLocal;

  /// Get file extension from fileName
  String get extension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Check file type
  bool get isPdf => extension == 'pdf';
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  bool get isDocument => ['doc', 'docx', 'txt', 'xlsx', 'xls'].contains(extension);

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id']?.toString(),
      fileName: json['file_name'] ?? json['fileName'] ?? 'Unknown',
      fileType: json['file_type'] ?? json['fileType'] ?? 'document',
      fileSize: json['file_size'] ?? json['fileSize'] ?? 0,
      fileUrl: json['file_url'] ?? json['fileUrl'] ?? json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'file_url': fileUrl,
    };
  }
}
