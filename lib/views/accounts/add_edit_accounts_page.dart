import 'package:dsv360/models/accounts.dart';
import 'package:dsv360/views/widgets/TopHeaderBar.dart';
import 'package:flutter/material.dart';

class AddEditAccountsPage extends StatefulWidget {
  final Account? account;
  const AddEditAccountsPage({super.key,required this.account});

  @override
  State<AddEditAccountsPage> createState() => _AddEditAccountsPageState();
}

class _AddEditAccountsPageState extends State<AddEditAccountsPage> {
  final _formKey = GlobalKey<FormState>();

  late bool isEditing;

  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _orgType;
  String? _orgStatus;

  @override
  void initState() {
    super.initState();
    isEditing = widget.account != null;

    if (isEditing) {
      final account = widget.account!;

      _clientNameController.text = account.orgName;
      _websiteController.text = account.website;
      _emailController.text = account.email;
      _orgType = account.orgType;
      _orgStatus = account.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopHeaderBar(heading: isEditing ? 'Edit Account' : 'Add Account'),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Account Information",
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
                      /// Client Name
                      TextFormField(
                        controller: _clientNameController,
                        decoration: _inputDecoration(context, 'Client Name'),
                        style: TextStyle(color: colors.onSurface),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter Client Name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      /// Website Address
                      TextFormField(
                        controller: _websiteController,
                        decoration: _inputDecoration(context, 'Website'),
                        style: TextStyle(color: colors.onSurface),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter Website address'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      /// Organization Status
                      DropdownButtonFormField<String>(
                        value: _orgStatus,
                        decoration: _inputDecoration(context, 'Organization Status'),
                        dropdownColor: colors.surface,
                        style: TextStyle(color: colors.onSurface),
                        items: const [
                          DropdownMenuItem(
                            value: 'Active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'DeActivate',
                            child: Text('DeActivate'),
                          ),
                        ],
                        onChanged: (value) => setState(() => _orgType = value),
                        validator: (value) =>
                            value == null ? 'Select status' : null,
                      ),
                      const SizedBox(height: 16),

                      /// Organization Type
                      DropdownButtonFormField<String>(
                        value: _orgType,
                        decoration: _inputDecoration(context, 'Organization Type'),
                        dropdownColor: colors.surface,
                        style: TextStyle(color: colors.onSurface),
                        items: const [
                          DropdownMenuItem(
                            value: 'Non-Profit',
                            child: Text('Non-Profit'),
                          ),
                          DropdownMenuItem(
                            value: 'Private Company',
                            child: Text('Private Company'),
                          ),
                          DropdownMenuItem(
                            value: 'Public Company',
                            child: Text('Public Company'),
                          ),
                          DropdownMenuItem(
                            value: 'Government Organization',
                            child: Text('Government Organization'),
                          ),
                          DropdownMenuItem(
                            value: 'Startup',
                            child: Text('Startup'),
                          ),
                        ],
                        onChanged: (value) => setState(() => _orgType = value),
                        validator: (value) =>
                            value == null ? 'Select Organization Type' : null,
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
                                isEditing ? 'SAVE CHANGES' : 'ADD ACCOUNT',
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