import 'package:dsv360/core/network/dio_client.dart';
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
  ConsumerState<AddClientContactsPage> createState() =>
      _AddClientContactsPageState();
}

class _AddClientContactsPageState extends ConsumerState<AddClientContactsPage> {
  final _formKey = GlobalKey<FormState>();

  late bool isEditing;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  String? _organization;
  String bottomTwoButtonsLoadingKey = 'add_client_key';

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

  Map<String, dynamic> _buildRequestBody() {
    return {
      'First_Name': _firstNameController.text.trim(),
      'Last_Name': _lastNameController.text.trim(),
      'Email': _emailController.text.trim(),
      'Org_Name': _organization.toString(),
      'Phone': _contactNumberController.text.trim(),
    };
  }

  Future<void> _createClientContact(Map<String, dynamic> body) async {
    final createBody = {
      ...body,
      'status': true,
    };

    try {
      await ApiClient.instance.post(
        'time_entry_management_application_function/addContact',
        data: createBody,
      );
    } catch (e) {
      // Fallback for environments where contact route is enabled.
      if (!e.toString().contains('404')) rethrow;
      await ApiClient.instance.post(
        'time_entry_management_application_function/contact',
        data: createBody,
      );
    }
  }

  Future<void> _updateClientContact(Map<String, dynamic> body) async {
    try {
      await ApiClient.instance.put(
        'time_entry_management_application_function/contact/${widget.clientContacts!.rowId}',
        data: body,
      );
    } catch (e) {
      // Fallback for environments still using legacy update route.
      if (!e.toString().contains('404')) rethrow;
      await ApiClient.instance.post(
        'time_entry_management_application_function/updateContact/${widget.clientContacts!.rowId}',
        data: body,
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_organization == null || _organization!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select organization')),
      );
      return;
    }

    ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state =
        true;

    final body = _buildRequestBody();
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
            isEditing
                ? 'Client contact updated successfully'
                : 'Client contact added successfully',
          ),
        ),
      );

      ref.invalidate(clientContactsListRepositoryProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save client contact')),
      );
    } finally {
      ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier).state =
          false;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Client Contact' : 'Add New Client Contact',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 12.0,
              ),
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
                      // First Name
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

                      // Last Name
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

                      // Email
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


                      // Organization
                      CustomDropDownField(
                        hintText: "Organization",
                        labelText: "Organization",
                        prefixIcon: Icons.business,
                        selectedOption: _organization,
                        options: [
                          DropdownMenuItem(
                            value: 'Wipro',
                            child: Text('Wipro'),
                          ),
                          DropdownMenuItem(
                            value: 'TCS',
                            child: Text('TCS'),
                          ),
                          DropdownMenuItem(
                            value: 'Accenture',
                            child: Text('Accenture'),
                          ),
                          DropdownMenuItem(
                            value: 'Fristine',
                            child: Text('Fristine'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _organization = value),
                      ),
                      const SizedBox(height: 16),

                      // Contact Number
                      CustomInputField(
                        controller: _contactNumberController,
                        hintText: 'Contact Number',
                        labelText: 'Contact Number',
                        prefixIcon: Icons.contact_emergency_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter contact number';
                          }

                          final phone = value.trim();

                          // Only digits
                          if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
                            return 'Only digits allowed';
                          }

                          // Length check (India: 10 digits)
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

                      //buttons
                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: "Cancel",
                        button2Text: isEditing ? "save changes" : "add client",
                        button1Function: () {
                          Navigator.pop(context);
                        },
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
