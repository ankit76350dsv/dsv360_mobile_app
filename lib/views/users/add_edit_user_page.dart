import 'package:dio/dio.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/users.dart';
import 'package:dsv360/repositories/users_repository.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditUserPage extends ConsumerStatefulWidget {
  final UsersModel? user;

  const AddEditUserPage({super.key, this.user});

  @override
  ConsumerState<AddEditUserPage> createState() => _AddEditUserPageState();
}

class _AddEditUserPageState extends ConsumerState<AddEditUserPage> {
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

  Map<String, dynamic> _buildRequestBody() {
    return {
      "first_name": _firstNameController.text.trim(),
      "last_name": _lastNameController.text.trim(),
      "email_id": _emailController.text.trim(),
      "role_id": _role, // this is roleId not label
    };
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
                          // these are hardcoded, need to change here
                          // ✍️✍️✍️✍️✍️✍️✍️✍️✍️✍️✍️✍️
                          DropdownMenuItem(
                            value: '17682000000035329',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: '17682000000035348',
                            child: Text('Manager/Team Lead'),
                          ),
                          DropdownMenuItem(
                            value: '17682000000035343',
                            child: Text('Intern'),
                          ),
                          DropdownMenuItem(
                            value: '17682000000035358',
                            child: Text('Developer'),
                          ),
                        ],
                        onChanged: (value) => setState(() => _role = value),
                      ),
                      const SizedBox(height: 16),

                      /// Email
                      CustomInputField(
                        controller: _emailController,
                        hintText: 'Enter Email ID',
                        enabled: !isEditing,
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
                        button2Function: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final body = _buildRequestBody();

                          try {
                            if (isEditing) {
                              // UPDATE USER (example)
                              // await DioClient.instance.put(
                              //   '/server/time_entry_management_application_function/UpdateEmployee',
                              //   : body,
                              // );
                            } else {
                              // ADD USER
                              final formData = FormData.fromMap(body);
                              await DioClient.instance.post(
                                '/server/time_entry_management_application_function/AddEmployees',
                                formData: formData,
                              );
                            }

                            Navigator.pop(context, true); // success

                            // throw current state and rebuild it from scratch
                            ref.invalidate(usersRepositoryProvider);
                          } catch (e) {
                            debugPrint('❌ Failed to submit user: $e');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to save user'),
                              ),
                            );
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
