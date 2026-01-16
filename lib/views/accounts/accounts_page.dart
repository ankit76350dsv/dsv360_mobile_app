import 'package:dsv360/models/accounts.dart';
import 'package:dsv360/repositories/accounts_list_repository.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/accounts/add_edit_accounts_page.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    final accountsListAsync = ref.watch(accountsListRepositoryProvider);
    final query = ref.watch(accountsSearchQueryProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: const Text('DSV-360'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white12,
            child: const Icon(Icons.person_outline, size: 18),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditAccountsPage(account: null),
            ),
          );
        },
        child: Icon(Icons.apartment, size: 22),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: TextField(
                style: TextStyle(color: colors.tertiary),
                onChanged: (value) {
                  ref.read(accountsSearchQueryProvider.notifier).state = value
                      .trim();
                },
                decoration: InputDecoration(
                  hintText: "Search accounts",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: colors.surfaceVariant,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0),
                child: accountsListAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (accounts) {
                    final filteredAccounts = accounts.where((a) {
                      final q = query.toLowerCase();
                      return a.orgName.toLowerCase().contains(q) ||
                          a.email.toLowerCase().contains(q) ||
                          a.website.toLowerCase().contains(q);
                    }).toList();

                    if (filteredAccounts.isEmpty) {
                      return const Center(child: Text('No accounts found'));
                    }

                    return ListView.builder(
                      itemCount: filteredAccounts.length,
                      itemBuilder: (context, index) {
                        return AccountsCard(account: filteredAccounts[index]);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountsCard extends ConsumerStatefulWidget {
  final Account account;
  const AccountsCard({super.key, required this.account});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountsCardState();
}

class _AccountsCardState extends ConsumerState<AccountsCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeUser = ref.watch(activeUserRepositoryProvider).asData?.value;

    return GestureDetector(
      onTap: () {},
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.account.orgName,
                        style: theme.textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),
                      CustomChip(
                        label: widget.account.orgType,
                        color: colors.primary,
                        icon: null,
                      ),
                      const SizedBox(width: 6.0),
                      CustomChip(
                        label: widget.account.status,
                        color: colors.primary,
                        icon: Icons.add_comment_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withOpacity(0.2),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _accountInfoRow(Icons.email, widget.account.email),
                            _websiteRow(
                              Icons.web_sharp,
                              widget.account.website,
                            ),
                            _accountInfoRow(Icons.tag, widget.account.rowId),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          CustomCardButton(
                            onTap: () {
                              // TODO: Handle edit action
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditAccountsPage(
                                    account: widget.account,
                                  ),
                                ),
                              );
                            },
                            icon: Icons.edit,
                          ),
                          const SizedBox(width: 5.0),
                          CustomCardButton(
                            onTap: () {
                              _showDeleteDialog(
                                context,
                                widget.account.orgName,
                              );
                            },
                            icon: Icons.delete,
                            color: colors.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Centralized role rule
  bool _canManageUsers(String role) {
    return role == 'Admin' || role == 'Manager';
  }

  /// Small helper for label-value rows
  Widget _infoRow(String label, String value) {
    final theme = Theme.of(context);

    final isWebsite = label.toLowerCase() == 'website';
    final websiteUrl = value.startsWith('http') ? value : 'https://$value';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14,
                color: isWebsite ? theme.colorScheme.primary : null,
                decoration: isWebsite ? TextDecoration.underline : null,
              ),
              recognizer: isWebsite
                  ? (TapGestureRecognizer()
                      ..onTap = () async {
                        final uri = Uri.parse(websiteUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      })
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Small helper for website-value row
  Widget _websiteRow(IconData icon, String value) {
    final theme = Theme.of(context);

    final websiteUrl = value.startsWith('http') ? value : 'https://$value';

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.tertiary),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            text: value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.parse(websiteUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
        ),
      ],
    );
  }

  Widget _accountInfoRow(IconData icon, String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.tertiary),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String orgName) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Delete Client', style: theme.textTheme.titleMedium),
          content: Text('Are you sure you want to delete Client "$orgName" ?'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: call delete API here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text('DELETE'),
            ),
          ],
        );
      },
    );
  }
}
