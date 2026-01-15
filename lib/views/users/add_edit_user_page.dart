import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/views/widgets/TopHeaderBar.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';

class AddEditUserPage extends StatefulWidget {
  final UsersModel? user;

  const AddEditUserPage({super.key, this.user});

  @override
  State<AddEditUserPage> createState() => _AddEditUserPageState();
}

class _AddEditUserPageState extends State<AddEditUserPage> {
  final _formKey = GlobalKey<FormState>();

  late bool isEditing;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _role;

  @override
  void initState() {
    super.initState();
    isEditing = widget.user != null;

    if (isEditing) {
      final user = widget.user!;

      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;

      _emailController.text = user.emailAddress;
      _role = user.role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user == null ? 'Add User' : 'Edit User',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              child: Text(
                "User Information",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// First Name
                      CustomInputField(
                        controller: _firstNameController,
                        hintText: 'Enter First Name',
                        labelText: 'First Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      /// Last Name
                      CustomInputField(
                        controller: _lastNameController,
                        hintText: 'Enter Last Name',
                        labelText: 'Last Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      /// Role
                      CustomDropDownField(
                        hintText: "Select Role",
                        labelText: "tole",
                        prefixIcon: Icons.business,
                        selectedOption: _role,
                        options: [
                          DropdownMenuItem(
                            value: 'Admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'Manager',
                            child: Text('Manager'),
                          ),
                          DropdownMenuItem(
                            value: 'Intern',
                            child: Text('Intern'),
                          ),
                          DropdownMenuItem(
                            value: 'Business Analyst',
                            child: Text('Business Analyst'),
                          ),
                        ],
                        onChanged: (value) => setState(() => _role = value),
                      ),
                      const SizedBox(height: 16),

                      /// Email
                      CustomInputField(
                        controller: _emailController,
                        hintText: 'Enter Email ID',
                        enabled: isEditing,
                        labelText: 'Email ID',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),
                      // buttons
                      BottomTwoButtons(
                        button1Text: "cancel", 
                        button2Text: isEditing ? 'SAVE CHANGES' : 'ADD USER',
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

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colors.surface,
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
