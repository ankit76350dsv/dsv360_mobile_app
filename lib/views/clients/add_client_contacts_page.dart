import 'package:dio/dio.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/features/accounts/reposetories/accounts_list_repository.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/core/constants/user_manager.dart';
import 'package:dsv360/models/client_contacts.dart';
import 'package:dsv360/repositories/client_contacts_repository.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddClientContactsPage extends ConsumerStatefulWidget {
  final ClientContacts? clientContacts;

  const AddClientContactsPage({super.key, this.clientContacts});

  @override
  ConsumerState<AddClientContactsPage> createState() => _AddClientContactsPageState();
}

class _AddClientContactsPageState extends ConsumerState<AddClientContactsPage> {
  final _formKey = GlobalKey<FormState>();

  late bool isEditing;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();

  String? _organization;
  final String bottomTwoButtonsLoadingKey = 'add_client_key';

  @override
  void initState() {
    super.initState();
    isEditing = widget.clientContacts != null;

    if (isEditing) {
      final contact = widget.clientContacts!;
      _firstNameController.text = contact.firstName;
      _lastNameController.text = contact.lastName;
      _emailController.text = contact.email;
      _contactNumberController.text = contact.phone;
      _organization = contact.orgName;
    }
  }

  Future<void> _createClientContact(Map<String, dynamic> body) async {
    await ApiClient.instance.post(
      'time_entry_management_application_function/addContact',
      data: body,
    );
  }

  Future<void> _updateClientContact(Map<String, dynamic> body) async {
    await ApiClient.instance.put(
      'time_entry_management_application_function/contact/${widget.clientContacts!.rowId}',
      data: body,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_organization == null || _organization!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select organization')),
      );
      return;
    }

    ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state = true;

    final accounts = ref.read(accountsListRepositoryProvider).value;
    final activeUser = ref.read(activeUserRepositoryProvider);
    final userProfile = UserManager.instance.userProfile;
    String? orgId;
    if (accounts != null) {
      try {
        final account = accounts.firstWhere((dynamic a) => a.orgName == _organization);
        orgId = account.rowId;
      } catch (_) {}
    }

    if (orgId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not determine OrgID for the selected organization.')),
      );
      ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state = false;
      return;
    }

   
    
    final creatorId =
        activeUser?.creatorId?.toString() ?? userProfile?.creatorId ?? '';
    final userId = activeUser?.userId?.toString() ?? userProfile?.userId ?? '';

    if (creatorId.isEmpty || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Missing user session fields (CREATORID/UserID). Please re-login and try again.',
          ),
        ),
      );
      ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state = false;
      return;
    }

    // ✅ Keys updated to match API contract:
    // first_name, last_name, email_id, org_name, org_id, phone
    final body = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email_id': _emailController.text.trim(),
      'org_name': _organization.toString(),
      'org_id': orgId,
      'phone': _contactNumberController.text.trim(),
      'status': 'true',
    };

    try {
      if (isEditing) {
        await _updateClientContact(body);
      } else {
        await _createClientContact(body);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Client contact updated successfully' : 'Client contact added successfully',
          ),
        ),
      );

      ref.invalidate(clientContactsListRepositoryProvider);
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Failed to save client contact';
      if (e is DioException) {
        errorMessage = 'Failed: ${e.response?.data ?? e.message}';
      } else {
        errorMessage = 'Failed: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state = false;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accountsListAsync = ref.watch(accountsListRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Client Contact' : 'Add New Client Contact',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text(
                "Client Contact Information",
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
                        controller: _firstNameController,
                        hintText: 'Enter First Name',
                        labelText: 'First Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: _lastNameController,
                        hintText: 'Enter Last Name',
                        labelText: 'Last Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        labelText: 'Email Address',
                        prefixIcon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      accountsListAsync.when(
                        data: (accounts) {
                          if (accounts.isEmpty) {
                            return CustomDropDownField(
                              hintText: "No accounts found",
                              labelText: "Organization",
                              prefixIcon: Icons.business,
                              selectedOption: null,
                              options: const [],
                              onChanged: (val) {},
                            );
                          }

                          final uniqueOrgNames = accounts.map((a) => a.orgName).toSet().toList();
                          final options = uniqueOrgNames
                              .map(
                                (orgName) => DropdownMenuItem<String>(
                                  value: orgName,
                                  child: Text(orgName),
                                ),
                              )
                              .toList();

                          if (_organization != null && !uniqueOrgNames.contains(_organization)) {
                            options.add(
                              DropdownMenuItem<String>(
                                value: _organization,
                                child: Text(_organization!),
                              ),
                            );
                          }

                          return CustomDropDownField(
                            hintText: "Organization",
                            labelText: "Organization",
                            prefixIcon: Icons.business,
                            selectedOption: _organization,
                            searchable: true,
                            searchHintText: 'Search organization',
                            options: options,
                            onChanged: (value) => setState(() => _organization = value),
                          );
                        },
                        loading: () => CustomDropDownField(
                          hintText: "Loading organizations...",
                          labelText: "Organization",
                          prefixIcon: Icons.business,
                          selectedOption: null,
                          options: const [],
                          onChanged: (val) {},
                        ),
                        error: (err, stack) => CustomDropDownField(
                          hintText: "Failed to load organizations",
                          labelText: "Organization",
                          prefixIcon: Icons.business,
                          selectedOption: null,
                          options: const [],
                          onChanged: (val) {},
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: _contactNumberController,
                        hintText: 'Contact Number',
                        labelText: 'Contact Number',
                        prefixIcon: Icons.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter contact number';
                          }

                          final phone = value.trim();
                          if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
                            return 'Only digits allowed';
                          }
                          if (phone.length != 10) {
                            return 'Enter valid 10-digit contact number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 32),
                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: "Cancel",
                        button2Text: isEditing ? "save changes" : "add client",
                        button1Function: () => Navigator.pop(context),
                        button2Function: _handleSubmit,
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