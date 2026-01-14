import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class AttachmentViewScreen extends StatefulWidget {
  final String attachment;
  final String type;

  const AttachmentViewScreen({
    super.key,
    required this.attachment,
    required this.type,
  });

  @override
  State<AttachmentViewScreen> createState() => _AttachmentViewScreenState();
}

class _AttachmentViewScreenState extends State<AttachmentViewScreen> {
  late PdfViewerController _pdfViewerController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    debugPrint('=== PDF VIEWER INIT ===');
    debugPrint('Attachment Type: ${widget.type}');
    debugPrint('Attachment URL: ${widget.attachment}');
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.attachment,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: widget.type == 'image'
            ? _buildImageViewer()
            : _buildPdfViewer(),
      ),
    );
  }

  Widget _buildImageViewer() {
    debugPrint('=== BUILDING IMAGE VIEWER ===');
    return InteractiveViewer(
      child: Image.asset(
        'assets/images/feedback.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image Error: $error');
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.broken_image,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Image not found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPdfViewer() {
    debugPrint('=== BUILDING PDF VIEWER ===');
    debugPrint('PDF URL: ${widget.attachment}');
    
    if (_error != null) {
      debugPrint('PDF Error State: $_error');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading PDF',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error ?? 'Unknown error',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return SfPdfViewer.network(
      widget.attachment,
      controller: _pdfViewerController,
      pageLayoutMode: PdfPageLayoutMode.single,
      canShowScrollHead: true,
      canShowPaginationDialog: true,
      scrollDirection: PdfScrollDirection.vertical,
      interactionMode: PdfInteractionMode.selection,
      enableDoubleTapZooming: true,
      enableTextSelection: true,
      canShowPasswordDialog: true,
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        debugPrint('=== PDF LOAD FAILED ===');
        debugPrint('Error: ${details.error}');
        setState(() {
          _error = 'Failed to load PDF: ${details.error}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${details.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      },
      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
        debugPrint('=== PDF LOADED SUCCESSFULLY ===');
        debugPrint('Pages: ${details.document.pages.count}');
      },
      onPageChanged: (PdfPageChangedDetails details) {
        debugPrint('Page changed: ${details.newPageNumber}');
      },
    );
  }
}
