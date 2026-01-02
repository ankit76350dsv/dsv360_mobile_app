import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/views/widgets/TopHeaderBar.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopHeaderBar(heading: isEditing ? 'Edit User' : 'Add User'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// First Name
                      TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDecoration(context, 'First Name'),
                        style: TextStyle(color: colors.onSurface),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter first name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      /// Last Name
                      TextFormField(
                        controller: _lastNameController,
                        decoration: _inputDecoration(context, 'Last Name'),
                        style: TextStyle(color: colors.onSurface),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter last name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      /// Role
                      DropdownButtonFormField<String>(
                        value: _role,
                        decoration: _inputDecoration(context, 'Role'),
                        dropdownColor: colors.surface,
                        style: TextStyle(color: colors.onSurface),
                        items: const [
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
                        validator: (value) =>
                            value == null ? 'Select role' : null,
                      ),
                      const SizedBox(height: 16),

                      /// Email
                      TextFormField(
                        controller: _emailController,
                        readOnly: isEditing,
                        decoration: _inputDecoration(context, 'Email ID'),
                        style: TextStyle(color: colors.onSurface),
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
                      Row(
                        children: [
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                splashColor: Colors.red.withOpacity(0.1),
                                highlightColor: Colors.red.withOpacity(0.1),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  foregroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                      color: Colors.red,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // TODO: Add / Update user logic
                                }
                              },
                              child: Text(
                                isEditing ? 'SAVE CHANGES' : 'ADD USER',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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
