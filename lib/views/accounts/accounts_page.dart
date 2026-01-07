import 'package:dsv360/models/accounts.dart';
import 'package:dsv360/repositories/accounts_list_repository.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/views/accounts/add_edit_accounts_page.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
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
                style: TextStyle(
                  color: colors.onSurfaceVariant, // ⭐ FIX
                ),
                onChanged: (value) {
                  ref.read(accountsSearchQueryProvider.notifier).state = value
                      .trim();
                },
                decoration: InputDecoration(
                  hintText: "Search accounts",
                  filled: true,
                  fillColor: colors.surfaceVariant,

                  prefixIcon: Icon(
                    Icons.search,
                    color: colors.onSurfaceVariant,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AccountsCard(account: filteredAccounts[index]),
                        );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: SizedBox(
          height: 280.00,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.apartment,
                        size: 28,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.account.orgName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Details
                _infoRow("Type", widget.account.orgType),
                _infoRow("Status", widget.account.status),
                _infoRow("Email", widget.account.email),
                _infoRow("Website", widget.account.displayWebsite),
                _infoRow("ROWID", widget.account.rowId),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Handle edit action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditAccountsPage(account: widget.account),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit_outlined, color: colors.primary),
                      color: colors.onSurface,
                      iconSize: 20,
                    ),
                    IconButton(
                      onPressed: () {
                        _showDeleteDialog(context, widget.account.orgName);
                      },
                      icon: const Icon(Icons.delete_outline),
                      color: colors.error,
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
