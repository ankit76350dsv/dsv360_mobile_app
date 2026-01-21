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

  String? _roleId;

  @override
  void initState() {
    super.initState();
    isEditing = widget.user != null;

    if (isEditing) {
      final user = widget.user!;

      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;

      _emailController.text = user.emailAddress;
      _roleId = user.roleId;
    }
  }

  Map<String, dynamic> _buildRequestBody() {
    return {
      "first_name": _firstNameController.text.trim(),
      "last_name": _lastNameController.text.trim(),
      "email_id": _emailController.text.trim(),
      "role_id": _roleId.toString(), // this is roleId not label
    };
  }

  String bottomTwoButtonsLoadingKey = 'add_edit_user';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    const Map<String, String> rolesMap = {
      "App Administrator": "17682000000037211",
      "App User": "17682000000037213",
      "Admin": "17682000000035329",
      "Super Admin": "17682000000035338",
      "Intern": "17682000000035343",
      "Manager/Team Lead": "17682000000035348",
      "Team Lead": "17682000000035353",
      "Developer": "17682000000035358",
      "Contacts": "17682000000035363",
      "Business Analyst": "17682000000035368",
      "MIS Analyst": "17682000000434126",
      "Sales": "17682000000659420",
      "Pre Sales": "17682000000659425",
    };

    final roleOptions = rolesMap.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.value, // 👈 role_id (IMPORTANT)
        child: Text(entry.key), // 👈 role name
      );
    }).toList();

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
                        labelText: "Role",
                        prefixIcon: Icons.business,
                        selectedOption: _roleId,
                        options: roleOptions,
                        onChanged: (value) => setState(() => _roleId = value),
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
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: "cancel",
                        button2Text: isEditing ? 'SAVE CHANGES' : 'ADD USER',
                        button1Function: () {
                          Navigator.pop(context);
                        },
                        button2Function: () async {
                          if (!_formKey.currentState!.validate()) return;
                          ref
                                  .read(
                                    submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier,
                                  )
                                  .state =
                              true;

                          final body = _buildRequestBody();
                          try {
                            if (isEditing) {
                              // UPDATE USER (example)
                              await DioClient.instance.post(
                                '/server/time_entry_management_application_function/UpdateEmployee/${widget.user!.userId}',
                                data: body,
                              );
                            } else {
                              final formData = FormData.fromMap(body);
                              // ADD USER
                              await DioClient.instance.post(
                                '/server/time_entry_management_application_function/AddEmployees',
                                data: formData,
                              );
                            }

                            Navigator.pop(context, true); // success

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEditing
                                      ? 'User updated successfully'
                                      : 'User added successfully',
                                ),
                              ),
                            );

                            // throw current state and rebuild it from scratch
                            ref.invalidate(usersRepositoryProvider);
                          } catch (e) {
                            debugPrint('❌ Failed to submit user: $e');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to save user'),
                              ),
                            );
                          } finally {
                            ref
                                .read(
                                  submitLoadingProvider(
                                    bottomTwoButtonsLoadingKey,
                                  ).notifier,
                                )
                                .state =
                            false;
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
