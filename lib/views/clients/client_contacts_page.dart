import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/models/client_contacts.dart';
import 'package:dsv360/repositories/active_user_repository.dart';
import 'package:dsv360/repositories/client_contacts_repository.dart';
import 'package:dsv360/views/clients/add_client_contacts_page.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/notifications/notification_page.dart';
import 'package:dsv360/views/widgets/app_snackbar.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:dsv360/views/widgets/custom_input_search.dart';
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
        toolbarHeight: 35.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Clients Contacts',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // if needed can add the icon as well here
        // hook for info action
        // you can open a dialog or screen here
        actions: [],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          // do nothing for the moment

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => AddClientContactsPage(clientContacts: null),
          //   ),
          // );
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
              child: CustomInputSearch(
                hint: "Search client contacts",
                searchProvider: clientContactsSearchQueryProvider,
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
                        return ClientContactsCard(
                          clientContacts: filteredClientContacts[index],
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
    final activeUser = ref.watch(activeUserRepositoryProvider);

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: colors.primary.withOpacity(0.15),
                        child: Icon(
                          Icons.filter_alt,
                          size: 22,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Column(
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
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 38,
                        height: 18,
                        child: Transform.scale(
                          scale: 0.70,
                          child: Switch(
                            value: widget.clientContacts.status,
                            onChanged: (value) async {
                              // do nothing for the moment
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      CustomCardButton(
                        onTap: () {
                          // do nothing for the moment

                          // _showDeleteDialog(
                          //   context,
                          //   "${widget.clientContacts.firstName} ${widget.clientContacts.lastName}",
                          // );
                        },
                        icon: Icons.delete,
                        color: colors.error,
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
                  /// Details
                  _clientInfoRow(Icons.tag, widget.clientContacts.userId),
                  _clientInfoRow(Icons.email, widget.clientContacts.email),
                  _clientInfoRow(
                    Icons.contact_emergency_outlined,
                    widget.clientContacts.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          content: Text(
            'Are you sure you want to delete Staff  "$clientContactName" ?',
          ),
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
