import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/utils/snackbar_utils.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/badges/view/pages/add_edit_badge_page.dart';
import 'package:dsv360/features/badges/view/pages/assign_badges_page.dart';
import 'package:dsv360/features/badges/view/pages/show_badges_page.dart';
import 'package:dsv360/features/badges/view/widgets/user_badge_card.dart';
import 'package:dsv360/features/users/repositories/users_repository.dart';
import 'package:dsv360/features/dashboard/view/widgets/AppDrawer.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/core/widgets/custom_input_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class BadgesPage extends ConsumerStatefulWidget {
  const BadgesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BadgesPageState();
}

class _BadgesPageState extends ConsumerState<BadgesPage> {
  bool _isRefreshingData = false;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final query = ref.watch(usersSearchQueryProvider);
    final usersAsync = ref.watch(usersRepositoryProvider);
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
        title: const Text(
          'Badges',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,size: 20,),
            onPressed: () async {
              if (_isRefreshingData) return;
              setState(() => _isRefreshingData = true);
              try {
                final _ = await ref.refresh(usersRepositoryProvider.future);
                if (mounted) {
                  
                  showSuccessSnackBar(context, 'Badges refreshed successfully');
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
          if (results.contains(ConnectivityResult.none)) return null;
          if (usersAsync.hasError) return null;

          return SpeedDial(
            backgroundColor: customColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.more_horiz,
            activeIcon: Icons.close,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.add_circle_outline_outlined),
                label: 'Add Badge',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddEditBadgePage()),
                  );
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.badge_outlined),
                label: 'Assign Badges',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AssignBadgesPage()),
                  );
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.emoji_events_outlined),
                label: 'Show Badges',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShowBadgesPage()),
                  );
                },
              ),
            ],
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

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: CustomInputSearch(
                    hint: 'Search users',
                    searchProvider: usersSearchQueryProvider,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: usersAsync.when(
                      loading: () =>
                          const GlobalLoader(message: 'Loading users badges...'),
                      error: (error, stack) => GlobalError(
                        message: 'Failed to load badges. Please try again.',
                        onRetry: () => ref.refresh(usersRepositoryProvider),
                      ),
                      data: (users) {
                        final filteredUsers = users.where((u) {
                          final q = query.toLowerCase();
                          return u.firstName.toLowerCase().contains(q) ||
                              u.lastName.toLowerCase().contains(q) ||
                              u.userId.toLowerCase().contains(q) ||
                              u.emailAddress.toLowerCase().contains(q) ||
                              u.role.toLowerCase().contains(q);
                        }).toList();

                        if (filteredUsers.isEmpty) {
                          return const Center(child: Text('No users found'));
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            final _ = await ref.refresh(
                              usersRepositoryProvider.future,
                            );
                          },
                          child: ListView.builder(
                            
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return UserBadgeCard(user: filteredUsers[index]);
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
