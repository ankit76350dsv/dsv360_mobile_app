import 'package:dsv360/models/dsvbadge.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';

class AddEditBadgePage extends StatefulWidget {
  final DSVBadge? badge;
  const AddEditBadgePage({super.key, this.badge});

  @override
  State<AddEditBadgePage> createState() => _AddEditBadgePageState();
}

class _AddEditBadgePageState extends State<AddEditBadgePage> {
  final _formKey = GlobalKey<FormState>();

  late bool isEditing;

  final TextEditingController _badgeIdController = TextEditingController();
  final TextEditingController _badgeNameController = TextEditingController();
  final TextEditingController _badgeLogoController = TextEditingController();
  String? _badgeLevel;
  String? _badgeLogo;

  @override
  void initState() {
    super.initState();
    isEditing = widget.badge != null;

    if (isEditing) {
      final badge = widget.badge!;

      _badgeIdController.text = badge.badgeId;
      _badgeNameController.text = badge.badgeName;
      _badgeLevel = badge.badgeLevel;
      _badgeLogo = badge.badgeLogo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.badge == null ? 'Add New Badge' : 'Edit Badge',
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
                "Badge Details",
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
                      // Badge Id
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

                      // Badge Name
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

                      // Badge Level
                      CustomDropDownField(
                        hintText: "Badge Level", 
                        labelText: "Badge Level", 
                        prefixIcon: Icons.badge,
                        options: [
                          DropdownMenuItem(
                            value: 'Bronze',
                            child: Text('Bronze'),
                          ),
                          DropdownMenuItem(
                            value: 'Silver',
                            child: Text('Silver'),
                          ),
                          DropdownMenuItem(
                            value: 'Gold',
                            child: Text('Gold'),
                          ),
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
                        onChanged: (value) => setState(() => _badgeLevel = value),
                      ),
                      const SizedBox(height: 20),

                      // Badge Logo
                      CustomInputField(
                        controller: _badgeLogoController,
                        hintText: 'Badge Logo',
                        labelText: 'Badge Logo',
                        prefixIcon: Icons.badge,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter badge logo';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),
                      // buttons
                      BottomTwoButtons(
                        button1Text: "cancel", 
                        button2Text: isEditing ? "save changes" : "add badge",
                        button1Function: () {
                          Navigator.pop(context);
                        },
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Add / Update user logic
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
