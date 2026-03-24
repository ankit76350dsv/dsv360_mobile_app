import 'package:dsv360/features/accounts/repositories/accounts_list_repository.dart';
import 'package:dsv360/features/client/model/client_contacts.dart';
import 'package:dsv360/features/client/viewmodel/client_contact_form_viewmodel.dart';
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(clientContactFormViewModelProvider).submitClientContact(
          context: context,
          isEditing: isEditing,
          bottomTwoButtonsLoadingKey: bottomTwoButtonsLoadingKey,
          organization: _organization,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phone: _contactNumberController.text,
          rowId: widget.clientContacts?.rowId,
        );
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