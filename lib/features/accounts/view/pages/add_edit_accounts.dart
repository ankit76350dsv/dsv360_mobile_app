import 'package:dsv360/features/accounts/model/accounts.dart';
import 'package:dsv360/features/accounts/viewmodel/account_form_viewmodel.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditAccountsPage extends ConsumerStatefulWidget {
  final Account? account;
  const AddEditAccountsPage({super.key, required this.account});

  @override
  ConsumerState<AddEditAccountsPage> createState() =>
      _AddEditAccountsPageState();
}

class _AddEditAccountsPageState extends ConsumerState<AddEditAccountsPage> {
  final _formKey = GlobalKey<FormState>();

  late bool isEditing;

  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _orgType;
  String? _orgStatus;

  String bottomTwoButtonsLoadingKey = 'add_edit_account_key';

  @override
  void initState() {
    super.initState();
    isEditing = widget.account != null;

    if (isEditing) {
      final account = widget.account!;

      _accountNameController.text = account.orgName;
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
      appBar: AppBar(
        backgroundColor: colors.surface,
        toolbarHeight: 35.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.account == null ? 'Add New Account' : 'Edit Account',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // if needed can add the icon as well here
        // hook for info action
        // you can open a dialog or screen here
        actions: [],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text(
                "Account Information",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
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
                      // Client Name
                      CustomInputField(
                        controller: _accountNameController,
                        hintText: 'Client Name',
                        labelText: 'Client Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter client name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Website Address
                      CustomInputField(
                        controller: _websiteController,
                        hintText: 'Website Address',
                        labelText: 'Website Address',
                        prefixIcon: Icons.web_sharp,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Add Website Address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Organization Status
                      CustomDropDownField(
                        hintText: "Organization Status",
                        labelText: "Organization Status",
                        prefixIcon: Icons.radio_button_checked_outlined,
                        selectedOption: _orgStatus,
                        options: [
                          DropdownMenuItem(
                            value: 'Active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'DeActivate',
                            child: Text('DeActivate'),
                          ),
                          DropdownMenuItem(
                            value: 'Inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _orgStatus = value),
                      ),
                      const SizedBox(height: 20),

                      // Organization Type
                      CustomDropDownField(
                        hintText: "Organization Type",
                        labelText: "Organization Type",
                        prefixIcon: Icons.business,
                        selectedOption: _orgType,
                        options: [
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
                          DropdownMenuItem(
                            value: 'Enterprise',
                            child: Text('Enterprise'),
                          ),
                        ],
                        onChanged: (value) => setState(() => _orgType = value),
                      ),

                      const SizedBox(height: 20.0),

                      // Email Address
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

                      const SizedBox(height: 32),

                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: "Cancel",
                        button2Text: isEditing ? "save changes" : "add account",
                        button1Function: () {
                          Navigator.pop(context);
                        },
                        button2Function: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final viewModel = ref.read(
                            accountFormViewModelProvider,
                          );

                          final body = viewModel.buildRequestBody(
                            email: _emailController.text,
                            accountName: _accountNameController.text.toString(),
                            orgType: _orgType,
                            orgStatus: _orgStatus,
                            website: _websiteController.text.toString(),
                          );

                          await viewModel.submitAccount(
                            context: context,
                            isEditing: isEditing,
                            bottomTwoButtonsLoadingKey:
                                bottomTwoButtonsLoadingKey,
                            orgStatus: _orgStatus,
                            orgType: _orgType,
                            rowId: widget.account?.rowId,
                            body: body,
                          );
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
