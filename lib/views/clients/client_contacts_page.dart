import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/models/client_contacts.dart';
import 'package:dsv360/repositories/client_contacts_repository.dart';
import 'package:dsv360/views/clients/add_client_contacts_page.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
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
    final customColors = Theme.of(context).custom;
    final connectivityStatus = ref.watch(connectivityStatusProvider);

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
      floatingActionButton: connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) {
            return null; // FAB hidden when no internet
          }

          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: customColors.primary,
            onPressed: () {
              // do nothing for the moment

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddClientContactsPage(clientContacts: null),
                ),
              );
            },
            child: Icon(Icons.filter_alt, size: 22, color: Colors.white),
          );
        },
        loading: () => null, // hide FAB while checking
        error: (_, __) => null, // hide FAB on error
      ),

      body: SafeArea(
        child: connectivityStatus.when(
          data: (results) {
            if (results.contains(ConnectivityResult.none)) {
              return GlobalError(
                message: 'Please check your internet connection.',
                isNetworkError: true,
                onRetry: () {
                  ref.invalidate(connectivityStatusProvider);
                },
              );
            }

            // When connected, show client contacts data
            return Column(
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
                      loading: () => const GlobalLoader(
                        message: 'Loading client contacts info...',
                      ),
                      error: (error, stack) => GlobalError(
                        message: 'Failed to load client contacts data: $error',
                        onRetry: () =>
                            ref.refresh(clientContactsListRepositoryProvider),
                      ),
                      data: (clientContactsList) {
                        final filteredClientContacts = clientContactsList.where(
                          (c) {
                            final q = query.toLowerCase();
                            return c.orgName.toLowerCase().contains(q) ||
                                c.email.toLowerCase().contains(q) ||
                                c.firstName.toLowerCase().contains(q) ||
                                c.lastName.toLowerCase().contains(q);
                          },
                        ).toList();

                        if (filteredClientContacts.isEmpty) {
                          return const Center(child: Text('No accounts found'));
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(clientContactsListRepositoryProvider);
                            await ref.read(
                              clientContactsListRepositoryProvider.future,
                            );
                          },
                          child: ListView.builder(
                            itemCount: filteredClientContacts.length,
                            itemBuilder: (context, index) {
                              return ClientContactsCard(
                                clientContacts: filteredClientContacts[index],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
          error: (error, stack) => GlobalError(
            message: 'Failed to check connectivity: $error',
            onRetry: () => ref.invalidate(connectivityStatusProvider),
          ),
          loading: () => const GlobalLoader(message: 'Checking connection...'),
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
  bool _isUpdatingStatus = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    clientStatus = widget.clientContacts.status;
  }

  @override
  void didUpdateWidget(covariant ClientContactsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUpdatingStatus &&
        oldWidget.clientContacts.status != widget.clientContacts.status) {
      clientStatus = widget.clientContacts.status;
    }
  }

  Future<void> _updateClientStatusWithFallback(bool newStatus) async {
    final Map<String, dynamic> body = {
      'status': newStatus,
      'ROWID': widget.clientContacts.rowId,
      'USERID': widget.clientContacts.userId,
    };

    try {
      // Primary route requested by backend contract.
      await ApiClient.instance.post(
        'time_entry_management_application_function/updateClientContactStatus',
        data: body,
      );
    } catch (e) {
      // Fallbacks for environments wired to different route styles.
      if (!e.toString().contains('404')) rethrow;

      try {
        await ApiClient.instance.put(
          'time_entry_management_application_function/updateClientContactStatus/${widget.clientContacts.rowId}',
          data: body,
        );
      } catch (e2) {
        if (!e2.toString().contains('404')) rethrow;
        await ApiClient.instance.put(
          'time_entry_management_application_function/contact/${widget.clientContacts.rowId}',
          data: body,
        );
      }
    }
  }

  Future<void> _confirmAndUpdateStatus(bool newStatus) async {
    if (_isUpdatingStatus) return;

    final fullName =
        '${widget.clientContacts.firstName} ${widget.clientContacts.lastName}';
    final action = newStatus ? 'set status to true' : 'set status to false';

    final confirmed = await showWarningDialogueBox<bool>(
      context: context,
      title: 'Change Client Status',
      subtitle: 'Are you sure you want to $action "$fullName"?',
      primaryText: 'CONFIRM',
    );

    if (confirmed != true) return;

    final previous = clientStatus;
    setState(() {
      clientStatus = newStatus;
      _isUpdatingStatus = true;
    });

    try {
      await _updateClientStatusWithFallback(newStatus);
      if (!mounted) return;

      ref.invalidate(clientContactsListRepositoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Client status updated to $newStatus successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        clientStatus = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update client status')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _deleteClientContactWithFallback() async {
    try {
      await ApiClient.instance.delete(
        'time_entry_management_application_function/contact/${widget.clientContacts.rowId}',
      );
    } catch (e) {
      // Fallback for environments still wired to legacy route names.
      if (!e.toString().contains('404')) rethrow;
      await ApiClient.instance.post(
        'time_entry_management_application_function/deleteContact/${widget.clientContacts.rowId}',
      );
    }
  }

  Future<void> _confirmAndDeleteClient() async {
    if (_isDeleting) return;

    final fullName =
        '${widget.clientContacts.firstName} ${widget.clientContacts.lastName}';
    final confirmed = await showWarningDialogueBox<bool>(
      context: context,
      title: 'Delete Client Contact',
      subtitle: 'Are you sure you want to delete "$fullName"?',
      primaryText: 'DELETE',
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _deleteClientContactWithFallback();
      if (!mounted) return;

      ref.invalidate(clientContactsListRepositoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client contact deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete client contact')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.custom;

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
                        backgroundColor: customColors.primary!.withOpacity(0.15),
                        child: Icon(
                          Icons.filter_alt,
                          size: 22,
                          color: customColors.primary,
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
                            value: clientStatus,
                            onChanged: _isUpdatingStatus
                                ? null
                                : (value) => _confirmAndUpdateStatus(value),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      CustomCardButton(
                        onTap: _isDeleting ? () {} : _confirmAndDeleteClient,
                        icon: Icons.delete,
                        color: customColors.error,
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
    final customColors = Theme.of(context).custom;

    return Row(
      children: [
        Icon(icon, size: 18, color: customColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: customColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
