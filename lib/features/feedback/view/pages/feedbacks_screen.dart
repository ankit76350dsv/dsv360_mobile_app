import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/features/feedback/view/pages/feedback_detail_screen.dart';
import 'package:dsv360/features/feedback/view/pages/feedback_form_screen.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/views/widgets/custom_input_search.dart';
import 'package:dsv360/views/widgets/feedback_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/feedback_model.dart';
import '../../repositories/feedback_repository.dart';

class FeedbacksScreen extends ConsumerStatefulWidget {
  final FeedbackModel? newFeedback;

  const FeedbacksScreen({super.key, this.newFeedback});

  @override
  ConsumerState<FeedbacksScreen> createState() => _FeedbacksScreenState();
}

class _FeedbacksScreenState extends ConsumerState<FeedbacksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Fixed', or 'Will Fix Soon'
  final List<String> _filterOptions = const ['All', 'Fixed', 'Will Fix Soon'];

  final userRole = AuthManager.instance.currentUser?.role?.name.toLowerCase();

  List<FeedbackModel> _filterFeedbacks(List<FeedbackModel> feedbacks) {
    var filtered = feedbacks;

    // Apply filter selection
    if (_selectedFilter == 'Fixed') {
      filtered = filtered.where((feedback) {
        return feedback.status == 'Resolved';
      }).toList();
    } else if (_selectedFilter == 'Will Fix Soon') {
      filtered = filtered.where((feedback) {
        return feedback.status != 'Resolved';
      }).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    // Initialize search controller with current query if needed
    _searchController.text = ref.read(feedbackSearchQueryProvider);

    // Auto-refresh data when page is visited
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.invalidate(feedbackRepositoryProvider);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final feedbackAsync = ref.watch(feedbackRepositoryProvider);
    final searchQuery = ref.watch(feedbackSearchQueryProvider);
    final connectivityStatus = ref.watch(checkConnectivityProvider);

    return Scaffold(
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
          'Feedbacks',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (userRole != 'admin' || userRole != 'admin') ? connectivityStatus.when(
        data: (results) {
          if (results.contains(ConnectivityResult.none)) {
            return null;
          }

          return FloatingActionButton(
            backgroundColor: customColors.primary,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FeedbackFormScreen()),
              );
            },
            child: Icon(Icons.feedback_rounded, size: 22),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ) : null,
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
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomInputSearch(
                                          searchProvider:
                                              feedbackSearchQueryProvider,
                                          hint: "Search feedbacks",
                                        ),
                                      ),
                                      if (AuthManager
                                              .instance
                                              .currentUser
                                              ?.role
                                              ?.name
                                              .toLowerCase() ==
                                          "admin")
                                        const SizedBox(width: 8),
                                      if (AuthManager
                                              .instance
                                              .currentUser
                                              ?.role
                                              ?.name
                                              .toLowerCase() ==
                                          "admin")
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: customColors.inputBorder!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: customColors.inputFill,
                                          ),
                                          child: PopupMenuButton<String>(
                                            color: customColors.inputFill,
                                            onSelected: (value) {
                                              setState(
                                                () => _selectedFilter = value,
                                              );
                                            },
                                            itemBuilder: (context) => _filterOptions
                                                .map(
                                                  (
                                                    option,
                                                  ) => PopupMenuItem<String>(
                                                    value: option,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          _selectedFilter ==
                                                                  option
                                                              ? Icons
                                                                    .radio_button_checked
                                                              : Icons
                                                                    .radio_button_unchecked,
                                                          color: customColors
                                                              .primary,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          option,
                                                          style: TextStyle(
                                                            color: customColors
                                                                .textPrimary,
                                                            fontWeight:
                                                                _selectedFilter ==
                                                                    option
                                                                ? FontWeight
                                                                      .w600
                                                                : FontWeight
                                                                      .w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.filter_list,
                                                color: customColors.textPrimary,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                Expanded(
                  child: feedbackAsync.when(
                    loading: () => const GlobalLoader(
                      message: 'Loading feedbacks info...',
                    ),
                    error: (error, stack) => GlobalError(
                      message: 'Failed to load feedbacks data: Try Again',
                      onRetry: () => ref.refresh(feedbackRepositoryProvider),
                    ),
                    data: (feedbacks) {
                      var displayFeedbacks = [...feedbacks];
                      if (widget.newFeedback != null &&
                          !displayFeedbacks.any(
                            (f) => f.id == widget.newFeedback!.id,
                          )) {
                        displayFeedbacks.insert(0, widget.newFeedback!);
                      }

                      try {
                        if (!IsHaveAccess.instance.isAdmin) {
                          final currentUser = AuthManager.instance.currentUser;
                          if (currentUser != null) {
                            final String? uid = (currentUser as dynamic).id
                                ?.toString();
                            if (uid != null && uid.isNotEmpty) {
                              displayFeedbacks = displayFeedbacks
                                  .where((f) => f.userId == uid)
                                  .toList();
                            }
                          }
                        }
                      } catch (e) {
                        debugPrint("Error filtering feedbacks: $e");
                      }

                      final filteredFeedbacks =
                          _filterFeedbacks(displayFeedbacks).where((feedback) {
                            if (searchQuery.isEmpty) return true;
                            final query = searchQuery.toLowerCase();
                            return feedback.name.toLowerCase().contains(
                                  query,
                                ) ||
                                feedback.email.toLowerCase().contains(query) ||
                                feedback.message.toLowerCase().contains(query);
                          }).toList()..sort(
                            (a, b) => b.date.compareTo(a.date),
                          ); // newest first

                      return RefreshIndicator(
                        onRefresh: () async {
                          final _ = await ref.refresh(
                            feedbackRepositoryProvider,
                          );
                        },
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                Text(
                                  '${filteredFeedbacks.length} Feedback${filteredFeedbacks.length != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: customColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (filteredFeedbacks.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.inbox,
                                            size: 64,
                                            color: customColors.textSecondary!
                                                .withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No feedbacks found',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: customColors.textSecondary!
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: filteredFeedbacks
                                        .map(
                                          (feedback) => GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FeedbackDetailScreen(
                                                        feedback: feedback,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: FeedbackCard(
                                              feedback: feedback,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const GlobalLoader(message: 'Checking connection...'),
          error: (error, stack) => GlobalError(
            message: 'Something went wrong. Please check your connection.',
            onRetry: () => ref.invalidate(checkConnectivityProvider),
          ),
        ),
      ),
    );
  }
}
