import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

/// Crop Image Page using crop_your_image
class CropImagePage extends StatefulWidget {
  final File imageFile;

  const CropImagePage({super.key, required this.imageFile});

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final CropController _controller = CropController();
  bool _isProcessing = false;

  Future<void> _handleCrop(Uint8List croppedImage) async {
    setState(() => _isProcessing = true);
    try {
      final tempDir = Directory.systemTemp;
      final croppedFile = File(
        '${tempDir.path}/cropped_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await croppedFile.writeAsBytes(croppedImage);
      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      debugPrint('Crop error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Image crop failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Profile Photo'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isProcessing
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    _controller.crop();
                  },
                ),
        ],
      ),
      body: Crop(
        image: widget.imageFile.readAsBytesSync(),
        controller: _controller,
        onCropped: _handleCrop,
        aspectRatio: 1.0,
        initialSize: 0.5,
        withCircleUi: true,
      ),
    );
  }
}
