import 'package:dsv360/models/accounts.dart';
import 'package:dsv360/models/client_contacts.dart';
import 'package:dsv360/repositories/accounts_list_repository.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/client_contacts_repository.dart';
import 'package:dsv360/views/clientContacts/add_client_contacts_page.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientContactsPage extends ConsumerStatefulWidget {
  const ClientContactsPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClientContactsState();
}

class _ClientContactsState extends ConsumerState<ClientContactsPage> {
  @override
  Widget build(BuildContext context) {
    final clientContactsListAsync = ref.watch(
      clientContactsListRepositoryProvider,
    );
    final query = ref.watch(clientContactsSearchQueryProvider);
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
              builder: (_) => AddClientContactsPage(clientContacts: null),
            ),
          );
        },
        child: Icon(Icons.filter_alt, size: 22),
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
                  ref.read(clientContactsSearchQueryProvider.notifier).state = value
                      .trim();
                },
                decoration: InputDecoration(
                  hintText: "Search client contacts",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: colors.surfaceVariant,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
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
                child: clientContactsListAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (clientContactsList) {
                    final filteredClientContacts = clientContactsList.where((
                      c,
                    ) {
                      final q = query.toLowerCase();
                      return c.orgName.toLowerCase().contains(q) ||
                          c.email.toLowerCase().contains(q) ||
                          c.firstName.toLowerCase().contains(q) ||
                          c.lastName.toLowerCase().contains(q);
                    }).toList();

                    if (filteredClientContacts.isEmpty) {
                      return const Center(child: Text('No accounts found'));
                    }

                    return ListView.builder(
                      itemCount: filteredClientContacts.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ClientContactsCard(
                            clientContacts: filteredClientContacts[index],
                          ),
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

class ClientContactsCard extends ConsumerStatefulWidget {
  final ClientContacts clientContacts;
  const ClientContactsCard({super.key, required this.clientContacts});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ClientContactsCardState();
}

class _ClientContactsCardState extends ConsumerState<ClientContactsCard> {
  late bool clientStatus;

  @override
  void initState() {
    super.initState();
    clientStatus = widget.clientContacts.status;
  }

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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.filter_alt,
                        size: 28,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.clientContacts.firstName} ${widget.clientContacts.lastName}",
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.clientContacts.orgName,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              ],),),

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
                /// Details
                _clientInfoRow(Icons.tag, widget.clientContacts.userId),
                _clientInfoRow(Icons.email, widget.clientContacts.email),
                _clientInfoRow(Icons.contact_emergency_outlined, widget.clientContacts.phone),

              ],),),

              // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withOpacity(0.2),
            ),

                Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    activeUser != null && _canManageUsers(activeUser.role)
                        ? SizedBox(
                                    width: 40,
                                    height: 18,
                                    child: Transform.scale(
                                    scale:
                                        0.80, 
                                    child: Switch(
                              value: clientStatus,

                              onChanged: (value) {
                                setState(() {
                                  clientStatus = value;
                                  // TODO: Update workStatus in backend
                                });

                                final message = value
                                    ? 'Employee is active'
                                    : 'Employee is inactive';

                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(message),
                                        ],
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                              },
                            ),),
                          )
                        : SizedBox(),
                    Container(
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showDeleteDialog(
                          context,
                          "${widget.clientContacts.firstName} ${widget.clientContacts.lastName}",
                        );
                      },
                      icon: const Icon(Icons.delete),
                      color: colors.error,
                      iconSize: 20,
                    ),),
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

  Widget _clientInfoRow(IconData icon, String text) {
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

  void _showDeleteDialog(BuildContext context, String clientContactName) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Delete Staff', style: theme.textTheme.titleMedium),
          content: Text('Are you sure you want to delete Staff  "$clientContactName" ?'),
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
