import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/network/dio_client.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/core/widgets/warning_dialogue_box.dart';
import 'package:dsv360/features/accounts/model/accounts.dart';
import 'package:dsv360/features/accounts/reposetories/accounts_list_repository.dart';
import 'package:dsv360/features/accounts/view/pages/add_edit_accounts.dart';
import 'package:dsv360/views/dashboard/AppDrawer.dart';
import 'package:dsv360/views/dashboard/dashboard_page.dart';
import 'package:dsv360/views/widgets/custom_card_button.dart';
import 'package:dsv360/views/widgets/custom_chip.dart';
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
                              return AccountsCard(
                                account: filteredAccounts[index],
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

class AccountsCard extends ConsumerStatefulWidget {
  final Account account;
  const AccountsCard({super.key, required this.account});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountsCardState();
}

class _AccountsCardState extends ConsumerState<AccountsCard> {
  bool _is404Error(Object error) {
    return error.toString().contains('404');
  }

  Future<void> _deleteAccountWithFallback(String rowId) async {
    try {
       await ApiClient.instance.delete(
        'time_entry_management_application_function/org/$rowId',
      );
      
      return;
    } 
      
     
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

   
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.custom;
    //never used
    //final activeUser = ref.watch(activeUserRepositoryProvider);

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
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.account.orgName,
                          style: theme.textTheme.bodyLarge,
                          softWrap: true,
                        ),
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
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: _accountInfoRow(Icons.email, widget.account.email),
            ),
                          
            
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              // do nothing for the moment

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
                              //do nothing for the moment

                              _showDeleteDialog(
                                context,
                                widget.account.orgName,
                              );
                            },
                            icon: Icons.delete,
                            color: customColors.error,
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                  SizedBox(height: 10,),
                  Divider(color: Colors.grey.shade200,),
                  Row(
                        children: [
                          CustomChip(
                        label: widget.account.orgType,
                        color: customColors.primary!,
                        icon: null,
                      ),
                      const SizedBox(width: 6.0),
                      CustomChip(
                        label: widget.account.status,
                        color: customColors.primary!,
                        icon: Icons.add_comment_outlined,
                      ),
                        ],
                      )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Small helper for website-value row
  Widget _websiteRow(IconData icon, String value) {
    final customColors = Theme.of(context).custom;

    final websiteUrl = value.startsWith('http') ? value : 'https://$value';

    return Row(
      children: [
        Icon(icon, size: 18, color: customColors.textSecondary),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () async {
            final uri = Uri.parse(websiteUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Open website',
            style: TextStyle(
              fontSize: 14,
              color: customColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _accountInfoRow(IconData icon, String text) {
    final customColors = Theme.of(context).custom;

    return Row(
      children: [
        Icon(icon, size: 18, color: customColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            softWrap: true,
            style: TextStyle(color: customColors.textSecondary),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String orgName) {
    showWarningDialogueBox<bool>(
      context: context,
      title: 'Delete Account',
      subtitle: 'Are you sure you want to delete Account "$orgName" ?',
      primaryText: 'DELETE',
      onPrimaryPressed: (dialogContext) async {
        try {
          await _deleteAccountWithFallback(widget.account.rowId);

          if (!mounted) return;
          Navigator.of(dialogContext).pop(true);
          ref.invalidate(accountsListRepositoryProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
        } catch (e) {
          if (!mounted) return;
          Navigator.of(dialogContext).pop(false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: $e')),
          );
        }
      },
    ).then((confirmed) {
      if (confirmed != true) {
        try {
          ref.invalidate(accountsListRepositoryProvider);
        } catch (e) {}
      }
    });
  }
}
