import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/feedback/repositories/create_feedback_repository.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../views/widgets/custom_input_field.dart';
import '../../../../views/widgets/primary_button.dart';
import '../../../../views/widgets/TopBar.dart';
import 'feedbacks_screen.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  
  // Repository instance
  final _feedbackRepository = CreateFeedbackRepository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = AuthManager.instance.currentUser;
    if (user != null) {
      _nameController.text = "${user.firstName} ${user.lastName}";
      _emailController.text = user.emailId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleImageUpload() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(limit: 3);

    if (images.isNotEmpty) {
      if ((_selectedImages.length + images.length) > 3) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only upload up to 3 images')),
          );
        }
        return;
      }
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final user = AuthManager.instance.currentUser;
        if (user == null) {
          throw Exception("User not found");
        }

        // Use CreateFeedbackRepository to submit feedback
        await _feedbackRepository.createFeedback(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          message: _messageController.text.trim(),
          images: _selectedImages,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback submitted successfully'),
            ),
          );
          _messageController.clear();
          setState(() {
            _selectedImages.clear();
          });

          // Navigate to feedbacks screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FeedbacksScreen(),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Something went wrong. Please try again.')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              title: AppStrings.feedbackFormTitle,
              onBack: () => Navigator.pop(context),
              actionIcon: Icons.list_alt,
              onInfoTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedbacksScreen()),
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 20),
                    
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          CustomInputField(
                            controller: _nameController,
                            hintText: AppStrings.nameHint,
                            labelText: 'Full Name',
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.name,
                            enabled: false, // Read-only
                            validator: FormValidators.validateName,
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          CustomInputField(
                            controller: _emailController,
                            hintText: AppStrings.emailHint,
                            labelText: 'Email Address',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false, // Read-only
                            validator: FormValidators.validateEmail,
                          ),
                          const SizedBox(height: 20),

                          // Message Field
                          CustomInputField(
                            controller: _messageController,
                            hintText: AppStrings.messageHint,
                            labelText: 'Your Feedback',
                            prefixIcon: Icons.message_outlined,
                            isMultiline: true,
                            maxLines: 6,
                            minLines: 6,
                            keyboardType: TextInputType.multiline,
                            validator: FormValidators.validateMessage,
                          ),
                          const SizedBox(height: 24),

                          // Upload Images Section
                          Text(
                            AppStrings.uploadUpTo3Images,
                            style: TextStyle(
                              color: customColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Selected Images Preview
                          if (_selectedImages.isNotEmpty) ...[
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _selectedImages.asMap().entries.map((entry) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: customColors.inputFill,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.file(
                                          File(_selectedImages[entry.key].path),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.image,
                                              size: 40,
                                              color: customColors.textSecondary,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -8,
                                      right: -8,
                                      child: IconButton(
                                        icon: Icon(Icons.cancel, color: customColors.error),
                                        onPressed: () {
                                          setState(() {
                                            _selectedImages.removeAt(entry.key);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Upload Button
                          OutlinedButton.icon(
                            onPressed: _selectedImages.length < 3 ? _handleImageUpload : null,
                            icon: const Icon(Icons.attach_file, size: 18),
                            label: const Text('ATTACHMENT', style: TextStyle(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: customColors.primary,
                              side: BorderSide(color: customColors.primary!),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          PrimaryButton(
                            text: AppStrings.submit,
                            onPressed: _handleSubmit,
                            isLoading: _isSubmitting,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}