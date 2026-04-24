import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/sprints/repositories/create_release_repository.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CreateReleasePage extends ConsumerStatefulWidget {
  final String projectId;

  const CreateReleasePage({super.key, required this.projectId});

  @override
  ConsumerState<CreateReleasePage> createState() => _CreateReleasePageState();
}

class _CreateReleasePageState extends ConsumerState<CreateReleasePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _releaseDate;

  final String _loadingKey = 'create_release_key';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final customColors = Theme.of(context).custom;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: customColors.primary!,
              onPrimary: Colors.white,
              surface: customColors.cardBackground!,
              onSurface: customColors.textPrimary!,
            ),
            dialogTheme: DialogThemeData(backgroundColor: customColors.cardBackground!),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _releaseDate = picked);
    }
  }

  Future<void> _createRelease(BuildContext context) async {
    if (_releaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a release date')),
      );
      return;
    }

    final submitLoadingNotifier =
        ref.read(submitLoadingProvider(_loadingKey).notifier);
    submitLoadingNotifier.state = true;

    try {
      final repo = ref.read(createReleaseRepositoryProvider);

      final formattedDate = DateFormat('yyyy-MM-dd').format(_releaseDate!);

      await repo.createRelease(
        title: _titleController.text.trim(),
        projctID: widget.projectId,
        description: _descriptionController.text.trim(),
        dueDate: formattedDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Release created successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create release')),
      );
    } finally {
      submitLoadingNotifier.state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).custom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Release',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text(
                'Release Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Release Title
                      CustomInputField(
                        controller: _titleController,
                        hintText: 'Release Title',
                        labelText: 'Release Title',
                        prefixIcon: Icons.rocket_launch_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter release title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                       // Release Date
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: customColors.inputFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: customColors.inputBorder!,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: customColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _releaseDate == null
                                      ? 'Release Date'
                                      : DateFormat('dd-MM-yyyy')
                                          .format(_releaseDate!),
                                  style: TextStyle(
                                    color: _releaseDate == null
                                        ? customColors.textHint
                                        : customColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      CustomInputField(
                        controller: _descriptionController,
                        hintText: 'Description',
                        isMultiline: true,
                        labelText: 'Description',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter description';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                     

                      BottomTwoButtons(
                        loadingKey: _loadingKey,
                        button1Text: 'cancel',
                        button2Text: 'create release',
                        button1Function: () => Navigator.pop(context),
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            _createRelease(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
