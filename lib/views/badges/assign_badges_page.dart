import 'package:dsv360/repositories/all_badges_list.dart';
import 'package:dsv360/repositories/users_repository.dart';
import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
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

  final selectedBadgeNameProvider = StateProvider<String?>((ref) => null);
  final selectedBadgeLevelProvider = StateProvider<String?>((ref) => null);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final usersAsync = ref.watch(usersRepositoryProvider);
    final List<DropdownMenuItem<String>> userOptions = usersAsync.when(
      data: (users) => users.map((u) {
        return DropdownMenuItem<String>(
          value: u.userId,
          child: Text("${u.firstName} ${u.lastName}"),
        );
      }).toList(),

      loading: () => [],
      error: (_, __) => [],
    );

    final allDsvBadgesList = ref.watch(allDSVBadgesListRepositoryProvider);
    final List<DropdownMenuItem<String>> dsvBadgesOptions = allDsvBadgesList
        .when(
          data: (badges) {
            final uniqueNames = <String>{}; // Set

            for (final b in badges) {
              if (b.badgeName.isNotEmpty) {
                uniqueNames.add(b.badgeName);
              }
            }

            return uniqueNames.map((name) {
              return DropdownMenuItem<String>(value: name, child: Text(name));
            }).toList();
          },
          loading: () => [],
          error: (_, __) => [],
        );

    final List<DropdownMenuItem<String>> badgeLevelOptions = allDsvBadgesList
        .when(
          data: (badges) {
            if (_selectedBadgeName == null) return [];

            final levels = badges
                .where((b) => b.badgeName == _selectedBadgeName)
                .map((b) => b.badgeLevel)
                .toSet()
                .toList();

            return levels.map((level) {
              return DropdownMenuItem<String>(value: level, child: Text(level));
            }).toList();
          },
          loading: () => [],
          error: (_, __) => [],
        );

    final badgeLevelsProvider = Provider<List<String>>((ref) {
      final selectedName = ref.watch(selectedBadgeNameProvider);
      final badgesAsync = ref.watch(allDSVBadgesListRepositoryProvider);

      return badgesAsync.maybeWhen(
        data: (badges) {
          if (selectedName == null) return [];

          return badges
              .where((b) => b.badgeName == selectedName)
              .map((b) => b.badgeLevel)
              .toSet()
              .toList();
        },
        orElse: () => [],
      );
    });

    final levels = ref.watch(badgeLevelsProvider);

    final badgeNames = ref
        .watch(allDSVBadgesListRepositoryProvider)
        .maybeWhen(
          data: (badges) => badges.map((b) => b.badgeName).toSet().toList(),
          orElse: () => [],
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
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
                "Assign Badge Details",
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
                      // dropdown of list of all users
                      CustomDropDownField(
                        hintText: usersAsync.isLoading
                            ? "Loading users..."
                            : usersAsync.hasError
                            ? "Failed to load users"
                            : "Select user",
                        labelText: "Username",
                        prefixIcon: Icons.person,
                        options: userOptions, // empty when loading/error
                        onChanged: userOptions.isEmpty
                            ? (value) {} // disables selection
                            : (value) =>
                                  setState(() => _selectedUserName = value),
                      ),
                      const SizedBox(height: 20),

                      // dropdown of list of all badges
                      CustomDropDownField(
                        hintText: "Select badge",
                        labelText: "Badge Name",
                        prefixIcon: Icons.badge,
                        options: badgeNames
                            .map(
                              (name) => DropdownMenuItem<String>(
                                value: name,
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        onChanged: dsvBadgesOptions.isEmpty
                            ? (value) {} // disables selection
                            : (value) => setState(() {
                                ref
                                        .read(
                                          selectedBadgeNameProvider.notifier,
                                        )
                                        .state =
                                    value;
                                ref
                                        .read(
                                          selectedBadgeLevelProvider.notifier,
                                        )
                                        .state =
                                    null;
                              }),
                      ),
                      const SizedBox(height: 20),

                      // dropdown of list of all badge levels
                      CustomDropDownField(
                        hintText: levels.isEmpty
                            ? "Select badge first"
                            : "Select badge level",
                        labelText: "Badge Level",
                        prefixIcon: Icons.layers,
                        options: levels
                            .map(
                              (l) => DropdownMenuItem(value: l, child: Text(l)),
                            )
                            .toList(),
                        onChanged: levels.isEmpty
                            ? (value) {}
                            : (value) => setState(
                                () =>
                                    ref
                                            .read(
                                              selectedBadgeLevelProvider
                                                  .notifier,
                                            )
                                            .state =
                                        value,
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Badge Id
                      CustomInputField(
                        controller: _badgeIdController,
                        hintText: 'Badge Id',
                        labelText: 'Badge Id',
                        prefixIcon: Icons.tag,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter badge id';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),
                      // buttons
                      BottomTwoButtons(
                        button1Text: "cancel",
                        button2Text: "assign badge",
                        button1Function: () {
                          Navigator.pop(context);
                        },
                        button2Function: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Add / Update user logic
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
