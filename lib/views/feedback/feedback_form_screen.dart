import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/form_validators.dart';
import '../../models/feedback_model.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/primary_button.dart';
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
  
  final List<String> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleImageUpload() {
    // TODO: Implement file picker
    if (_selectedImages.length < 3) {
      setState(() {
        _selectedImages.add('feedback_image_${_selectedImages.length + 1}');
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final feedback = FeedbackModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
        images: List.from(_selectedImages),
        date: DateTime.now(),
        status: 'Pending',
      );

      setState(() {
        _isSubmitting = false;
        
        // Clear form
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        _selectedImages.clear();
      });

      // Navigate to feedbacks screen with new feedback
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedbacksScreen(newFeedback: feedback),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // drawer: const AppDrawer(currentRoute: Routes.feedback),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Header with Icon and Title
            Row(
              children: [
                // Container(
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: AppColors.primary,
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                //   child: const Icon(
                //     Icons.edit_note,
                //     color: AppColors.textWhite,
                //     size: 32,
                //   ),
                // ),
                // const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    AppStrings.feedbackFormTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeedbacksScreen()),
                    );
                  },
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: const Text('Check'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
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
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset(
                                    'assets/images/feedback.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.image,
                                        size: 40,
                                        color: AppColors.textSecondary,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel, color: AppColors.error),
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
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
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
      );
  
  }
}
