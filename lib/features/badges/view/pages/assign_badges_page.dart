import 'package:dsv360/features/badges/model/badge_user.dart';
import 'package:dsv360/features/badges/model/dsvbadge.dart';
import 'package:dsv360/features/badges/viewmodel/badges_viewmodel.dart';
import 'package:dsv360/core/widgets/bottom_two_buttons.dart';
import 'package:dsv360/core/widgets/custom_dropdown_field.dart';
import 'package:dsv360/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignBadgesPage extends ConsumerStatefulWidget {
  const AssignBadgesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AssignBadgesPageState();
}

class _AssignBadgesPageState extends ConsumerState<ConsumerStatefulWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _badgeIdController = TextEditingController();
  String? _selectedBadgeLevel;
  String? _selectedUserName;
  String? _selectedBadgeName;
  String? _selectedUserId;
  String? _selectedProfileLink;
  String? _selectedBadgeRowId;
  String? _selectedBadgeLogo;

  bool _isUsersLoading = true;
  bool _isBadgesLoading = true;
  bool _hasUsersError = false;
  bool _hasBadgesError = false;

  List<BadgeUser> _users = [];
  List<DSVBadge> _badges = [];

  String bottomTwoButtonsLoadingKey = 'assign_badge_key';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _badgeIdController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchUsers(),
      _fetchBadges(),
    ]);
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isUsersLoading = true;
      _hasUsersError = false;
    });

    try {
      _users = await ref.read(assignBadgesViewModelProvider).fetchUsers();
    } catch (_) {
      _hasUsersError = true;
      _users = [];
    } finally {
      if (mounted) {
        setState(() {
          _isUsersLoading = false;
        });
      }
    }
  }

  Future<void> _fetchBadges() async {
    setState(() {
      _isBadgesLoading = true;
      _hasBadgesError = false;
    });

    try {
      _badges = await ref.read(assignBadgesViewModelProvider).fetchBadges();
    } catch (_) {
      _hasBadgesError = true;
      _badges = [];
    } finally {
      if (mounted) {
        setState(() {
          _isBadgesLoading = false;
        });
      }
    }
  }

  Future<void> _assignBadge({required BuildContext context}) async {
    if (_selectedUserName == null || _selectedUserName!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select user')),
      );
      return;
    }

    if (_selectedBadgeName == null || _selectedBadgeName!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select badge name')),
      );
      return;
    }

    if (_selectedBadgeLevel == null || _selectedBadgeLevel!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select badge level')),
      );
      return;
    }

    if (_selectedUserId == null || _selectedUserId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected user not found')),
      );
      return;
    }

    if (_selectedBadgeRowId == null || _selectedBadgeRowId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected badge not found')),
      );
      return;
    }

    final submitLoadingNotifier =
      ref.read(submitLoadingProvider(bottomTwoButtonsLoadingKey).notifier);
    submitLoadingNotifier.state = true;

    try {
      final payload = {
        'Username': _selectedUserName,
        'UserID': _selectedUserId,
        'BadgeRowID': _selectedBadgeRowId,
        'Badge_Name': _selectedBadgeName,
        'Badge_Level': _selectedBadgeLevel,
        'Badge_Logo': _selectedBadgeLogo,
        'Badge_ID': _badgeIdController.text.trim(),
        'Profile_Link': _selectedProfileLink,
      };

      await ref
          .read(assignBadgesViewModelProvider)
          .assignBadge(context: context, payload: payload);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to assign badge')),
      );
    } finally {
      submitLoadingNotifier.state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final List<DropdownMenuItem<String>> userOptions = _users.map((u) {
      return DropdownMenuItem<String>(
        value: u.fullName,
        child: Text(u.fullName),
      );
    }).toList();

    final badgeNames = _badges
        .map((b) => b.badgeName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    final levels = _badges
        .where((b) => b.badgeName == _selectedBadgeName)
        .map((b) => b.badgeLevel)
        .where((level) => level.isNotEmpty)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assign Badge',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text(
                'Assign Badge Details',
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
                      CustomDropDownField(
                        hintText: _isUsersLoading
                            ? 'Loading users...'
                            : _hasUsersError
                            ? 'Failed to load users'
                            : 'Select user',
                        labelText: 'Username',
                        prefixIcon: Icons.person,
                        searchable: true,
                        searchHintText: 'Search user',
                        options: userOptions,
                        onChanged: userOptions.isEmpty
                            ? (value) {}
                            : (value) => setState(() {
                                _selectedUserName = value;
                                final selectedUser = _users.firstWhere(
                                  (u) => u.fullName == value,
                                  orElse: () => const BadgeUser(
                                    fullName: '',
                                    userId: '',
                                    profileLink: '',
                                  ),
                                );
                                _selectedUserId = selectedUser.userId;
                                _selectedProfileLink = selectedUser.profileLink;
                              }),
                      ),
                      const SizedBox(height: 20),
                      CustomDropDownField(
                        hintText: _isBadgesLoading
                            ? 'Loading badges...'
                            : _hasBadgesError
                            ? 'Failed to load badges'
                            : 'Select badge',
                        labelText: 'Badge Name',
                        prefixIcon: Icons.badge,
                        searchable: true,
                        searchHintText: 'Search badge name',
                        options: badgeNames
                            .map(
                              (name) => DropdownMenuItem<String>(
                                value: name,
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        onChanged: badgeNames.isEmpty
                            ? (value) {}
                            : (value) => setState(() {
                                _selectedBadgeName = value;
                                _selectedBadgeLevel = null;
                                _selectedBadgeRowId = null;
                                _selectedBadgeLogo = null;
                                _badgeIdController.clear();
                              }),
                      ),
                      const SizedBox(height: 20),
                      CustomDropDownField(
                        hintText:
                            levels.isEmpty ? 'Select badge first' : 'Select badge level',
                        labelText: 'Badge Level',
                        prefixIcon: Icons.layers,
                        searchable: true,
                        searchHintText: 'Search badge level',
                        options: levels
                            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: levels.isEmpty
                            ? (value) {}
                            : (value) => setState(() {
                                _selectedBadgeLevel = value;
                                final selectedBadge = _badges.firstWhere(
                                  (b) =>
                                      b.badgeName == _selectedBadgeName &&
                                      b.badgeLevel == value,
                                  orElse: () => DSVBadge(
                                    badgeLevel: '',
                                    badgeName: '',
                                    badgeLogo: '',
                                    badgeId: '',
                                    rowId: '',
                                  ),
                                );
                                _selectedBadgeRowId = selectedBadge.rowId;
                                _selectedBadgeLogo = selectedBadge.badgeLogo;
                                _badgeIdController.text = selectedBadge.badgeId;
                              }),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedBadgeLogo != null && _selectedBadgeLogo!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colors.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Image.network(
                                _selectedBadgeLogo!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      if (_selectedBadgeLogo != null && _selectedBadgeLogo!.isNotEmpty)
                        const SizedBox(height: 20),
                      CustomInputField(
                        controller: _badgeIdController,
                        hintText: 'Badge Id',
                        labelText: 'Badge Id',
                        prefixIcon: Icons.tag,
                        enabled: _badgeIdController.text.isEmpty,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter badge id';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      BottomTwoButtons(
                        loadingKey: bottomTwoButtonsLoadingKey,
                        button1Text: 'cancel',
                        button2Text: 'assign badge',
                        button1Function: () {
                          Navigator.pop(context);
                        },
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            _assignBadge(context: context);
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
}
