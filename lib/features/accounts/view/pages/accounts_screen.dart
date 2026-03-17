import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/accounts/reposetories/accounts_list_repository.dart';
import 'package:dsv360/features/accounts/view/pages/add_edit_accounts.dart';
import 'package:dsv360/features/accounts/view/widgets/accounts_card.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          'Accounts',
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
            onPressed: () async {
              // Open the Add Account screen.
              // Passing `account: null` means "create new" mode.
              final bool? result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditAccountsPage(account: null),
                ),
              );

              // If the Add screen reports success, refresh the list.
              if (result == true && mounted) {
                ref.refresh(accountsListRepositoryProvider);
              }
            },
            child: Icon(Icons.add, size: 28, color: Colors.white),
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

            // When connected, show accounts data
            return Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: TextField(
                    style: TextStyle(color: customColors.textPrimary),
                    onChanged: (value) {
                      ref.read(accountsSearchQueryProvider.notifier).state =
                          value.trim();
                    },
                    decoration: InputDecoration(
                      hintText: "Search accounts",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: customColors.surfaceBackground,
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
                          color: Colors.grey.shade600,
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
                      loading: () => const GlobalLoader(
                        message: 'Loading accounts info...',
                      ),
                      error: (error, stack) => GlobalError(
                        message: 'Failed to load dashboard data: $error',
                        onRetry: () =>
                            ref.refresh(accountsListRepositoryProvider),
                      ),
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

                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.refresh(accountsListRepositoryProvider);
                          },
                          child: ListView.builder(
                            itemCount: filteredAccounts.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  AccountsCard(
                                    account: filteredAccounts[index],
                                  ),
                                  SizedBox(height: 10,),
                                ],
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
