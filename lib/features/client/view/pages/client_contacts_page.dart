import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/client/repositories/client_contacts_repository.dart';
import 'package:dsv360/features/client/view/pages/add_client_contacts_page.dart';
import 'package:dsv360/features/client/view/widgets/client_contacts_card.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
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
        title: const Text(
          'Clients Contacts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: const [],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) {
            return null;
          }
          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: customColors.primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddClientContactsPage(clientContacts: null),
                ),
              );
            },
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          );
        },
        loading: () => null,
        error: (_, __) => null,
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          loading: () =>
              const GlobalLoader(message: 'Checking connection...'),
        ),
      ),
    );
  }
}