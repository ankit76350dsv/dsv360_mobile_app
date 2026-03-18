import 'package:dsv360/features/badges/model/dsvbadge.dart';
import 'package:dsv360/features/badges/viewmodel/add_edit_badge_viewmodel.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditBadgePage extends ConsumerStatefulWidget {
  const AddEditBadgePage({super.key, this.badge});

  final DSVBadge? badge;

  @override
  ConsumerState<AddEditBadgePage> createState() => _AddEditBadgePageState();
}

class _AddEditBadgePageState extends ConsumerState<AddEditBadgePage> {
  final _formKey = GlobalKey<FormState>();

  late bool isEditing;
  bool _isLoading = false;

  final TextEditingController _badgeIdController = TextEditingController();
  final TextEditingController _badgeNameController = TextEditingController();
  final TextEditingController _badgeLogoController = TextEditingController();
  String? _badgeLevel;
  String? _badgeLogo;

  String bottomTwoButtonsLoadingKey = 'add_edit_badge_key';

  @override
  void initState() {
    super.initState();
    isEditing = widget.badge != null;

    if (isEditing) {
      final viewModel = ref.read(addEditBadgeViewModelProvider);
      final badge = widget.badge!;

      _badgeIdController.text = badge.badgeId;
      _badgeNameController.text = badge.badgeName;
      _badgeLevel = viewModel.normalizeBadgeLevel(badge.badgeLevel);
      _badgeLogo =
          AddEditBadgeViewModel.badgeLevelLogoMap[_badgeLevel] ?? badge.badgeLogo;
    }
  }

  @override
  void dispose() {
    _badgeIdController.dispose();
    _badgeNameController.dispose();
    _badgeLogoController.dispose();
    super.dispose();
  }

  Future<void> _submitBadge(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final viewModel = ref.read(addEditBadgeViewModelProvider);
      final body = viewModel.buildRequestBody(
        badgeId: _badgeIdController.text,
        badgeName: _badgeNameController.text,
        badgeLevel: _badgeLevel,
        badgeLogo: _badgeLogo,
      );

      await viewModel.submitBadge(context: context, badge: widget.badge, body: body);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save badge')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.badge == null ? 'Add New Badge' : 'Edit Badge',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                'Badge Details',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInputField(
                        controller: _badgeIdController,
                        hintText: 'Badge Id',
                        labelText: 'Badge Id',
                        prefixIcon: Icons.tag,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter badge id';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        controller: _badgeNameController,
                        hintText: 'Badge Name',
                        labelText: 'Badge Name',
                        prefixIcon: Icons.badge,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter badge name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomDropDownField(
                        hintText: 'Badge Level',
                        labelText: 'Badge Level',
                        prefixIcon: Icons.badge,
                        selectedOption: _badgeLevel,
                        options: const [
                          DropdownMenuItem(value: 'Bronze', child: Text('Bronze')),
                          DropdownMenuItem(value: 'Silver', child: Text('Silver')),
                          DropdownMenuItem(value: 'Gold', child: Text('Gold')),
                          DropdownMenuItem(
                            value: 'Diamond',
                            child: Text('Diamond'),
                          ),
                          DropdownMenuItem(
                            value: 'Platinum',
                            child: Text('Platinum'),
                          ),
                          DropdownMenuItem(
                            value: 'Titanium',
                            child: Text('Titanium'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _badgeLevel = value;
                            if (value != null &&
                                AddEditBadgeViewModel.badgeLevelLogoMap.containsKey(
                                  value,
                                )) {
                              _badgeLogoController.text =
                                  AddEditBadgeViewModel.badgeLevelLogoMap[value]!;
                              _badgeLogo =
                                  AddEditBadgeViewModel.badgeLevelLogoMap[value];
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_badgeLogo != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colors.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Image.network(
                                _badgeLogo!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: 'cancel',
                        button2Text: isEditing ? 'save changes' : 'add badge',
                        button1Function: () {
                          if (!_isLoading) {
                            Navigator.pop(context);
                          }
                        },
                        button2Function: () {
                          if (!_isLoading && _formKey.currentState!.validate()) {
                            _submitBadge(context);
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
