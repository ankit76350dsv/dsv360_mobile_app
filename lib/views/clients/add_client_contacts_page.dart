import 'package:dsv360/models/client_contacts.dart';
import 'package:dsv360/views/widgets/TopHeaderBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AddClientContactsPage extends StatefulWidget {
  final ClientContacts? clientContacts;

  const AddClientContactsPage({super.key, this.clientContacts});

  @override
  State<AddClientContactsPage> createState() => _AddClientContactsPageState();
}

class _AddClientContactsPageState extends State<AddClientContactsPage> {
  final _formKey = GlobalKey<FormState>();

  late bool isEditing;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  String? _organization;

  @override
  void initState() {
    super.initState();

    isEditing = false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopHeaderBar(
              heading: isEditing ? 'Edit Client Contact' : 'Add Client Contact',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
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
                      const SizedBox(height: 16),

                      /// Role
                      DropdownButtonFormField<String>(
                        value: _organization,
                        decoration: _inputDecoration(context, 'Organization'),
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
                        onChanged: (value) =>
                            setState(() => _organization = value),
                        validator: (value) =>
                            value == null ? 'Select Organization' : null,
                      ),
                      const SizedBox(height: 16),

                      /// Contact Number
                      TextFormField(
                        controller: _contactNumberController,
                        readOnly: isEditing,
                        decoration: _inputDecoration(context, 'Contact Number'),
                        style: TextStyle(color: colors.onSurface),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                      ),

                      const SizedBox(height: 32),
                      // buttons
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 30.0,
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
                                isEditing
                                    ? 'SAVE CHANGES'
                                    : 'ADD CLIENT CONTACT',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
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
