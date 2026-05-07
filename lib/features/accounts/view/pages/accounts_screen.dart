import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/accounts/viewmodel/accounts_list_viewmodel.dart';
import 'package:dsv360/features/accounts/view/pages/add_edit_accounts.dart';
import 'package:dsv360/features/accounts/view/widgets/accounts_card.dart';
import 'package:dsv360/features/dashboard/view/widgets/AppDrawer.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/core/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  bool _isRefreshingData = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsListAsync = ref.watch(accountsListRepositoryProvider);
    final query = ref.watch(accountsSearchQueryProvider);
    final customColors = Theme.of(context).custom;
    final connectivityStatus = ref.watch(checkConnectivityProvider);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,size: 20,),
            onPressed: () async {
              if (_isRefreshingData) return;
              setState(() => _isRefreshingData = true);
              try {
                final _ = await ref.refresh(accountsListRepositoryProvider.future);
                if (mounted) {
                 
                  showSuccessSnackBar(context, 'Accounts refreshed successfully');
                }
              } catch (e) {
                debugPrint('Refresh error: $e');
                if (mounted) {
                 
                  showErrorSnackBar(context, 'Refresh failed. Please try again.');
                }
              } finally {
                if (mounted) {
                  setState(() => _isRefreshingData = false);
                }
              }
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) {
            return null;
          }
          if (accountsListAsync.hasError) {
            return null;
          }

          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: customColors.primary,
            onPressed: () async {
              final bool? result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditAccountsPage(account: null),
                ),
              );

              if (result == true && mounted) {
                ref.invalidate(accountsListRepositoryProvider);
              }
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
                  ref.invalidate(checkConnectivityProvider);
                },
              );
            }

            // When connected, show accounts data
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: CustomSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(accountsSearchQueryProvider.notifier).state =
                          value.trim();
                    },
                    hintText: 'Search accounts',
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
                        message: 'Failed to load data. Please try again.',
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
                            ref.invalidate(accountsListRepositoryProvider);
                          },
                          child: ListView.builder(
                            itemCount: filteredAccounts.length + 1,
                            itemBuilder: (context, index) {
                              if (index == filteredAccounts.length ) {
                                      return const SizedBox(height: 60);
                                    }
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
            message: 'Something went wrong. Please check your connection.',
            onRetry: () => ref.invalidate(checkConnectivityProvider),
          ),
          loading: () => const GlobalLoader(message: 'Checking connection...'),
        ),
      ),
    );
  }
}
