import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/sprints/repositories/create_epic_repository.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateEpicPage extends ConsumerStatefulWidget {
  final String projectId;
  final String milestoneId;

  const CreateEpicPage({
    super.key,
    required this.projectId,
    required this.milestoneId,
  });

  @override
  ConsumerState<CreateEpicPage> createState() => _CreateEpicPageState();
}

class _CreateEpicPageState extends ConsumerState<CreateEpicPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final String _loadingKey = 'create_epic_key';

  String? _selectedColor;

  final List<String> _colors = [
    "#FA9921",
    "#FAC304",
    "#2A53CC",
    "#2AA3BF",
    "#58D8A4",
    "#8677D9",
    "#5244AA",
    "#FA7353",
    "#3984FF",
    "#34C7E6",
    "#138759",
    "#DD350C",
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createEpic(BuildContext context) async {
    if (_selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a color')),
      );
      return;
    }

    final submitLoadingNotifier =
        ref.read(submitLoadingProvider(_loadingKey).notifier);
    submitLoadingNotifier.state = true;

    try {
      final repo = ref.read(createEpicRepositoryProvider);

      await repo.createEpic(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        projectId: widget.projectId,
        milestoneId: widget.milestoneId,
        color: _selectedColor!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Epic created successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create epic')),
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
          'Create Epic',
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
                'Epic Details',
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
                      /// Epic Title
                      CustomInputField(
                        controller: _titleController,
                        hintText: 'Epic Title',
                        labelText: 'Epic Title',
                        prefixIcon: Icons.flag_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter epic title';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Description
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

                      const SizedBox(height: 20),

                      /// Color Picker
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: customColors.inputFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: customColors.inputBorder!,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Epic Color',
                              style: TextStyle(
                                color: customColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),

                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _colors.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final colorHex = _colors[index];
                                  final color = Color(
                                    int.parse(colorHex.replaceAll('#', '0xFF')),
                                  );

                                  final isSelected =
                                      _selectedColor == colorHex;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = colorHex;
                                      });
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? colors.primary
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// Buttons (same component reused)
                      BottomTwoButtons(
                        loadingKey: _loadingKey,
                        button1Text: 'cancel',
                        button2Text: 'create epic',
                        button1Function: () => Navigator.pop(context),
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            _createEpic(context);
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