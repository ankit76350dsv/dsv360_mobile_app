import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/core/network/connectivity_provider.dart';
import 'package:dsv360/core/widgets/global_error.dart';
import 'package:dsv360/core/widgets/global_loader.dart';
import 'package:dsv360/features/dashboard/view/pages/dashboard_page.dart';
import 'package:dsv360/views/feedback/feedback_form_screen.dart';
import 'package:dsv360/core/constants/auth_manager.dart';
import 'package:dsv360/core/constants/is_have_access.dart';
import 'package:dsv360/views/widgets/custom_input_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/feedback_model.dart';
import '../../repositories/feedback_repository.dart';
import '../widgets/feedback_card.dart';
import 'feedback_detail_screen.dart';

class FeedbacksScreen extends ConsumerStatefulWidget {
  final FeedbackModel? newFeedback;

  const FeedbacksScreen({super.key, this.newFeedback});

  @override
  ConsumerState<FeedbacksScreen> createState() => _FeedbacksScreenState();
}

class _FeedbacksScreenState extends ConsumerState<FeedbacksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize search controller with current query if needed
    _searchController.text = ref.read(feedbackSearchQueryProvider);
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
    final connectivityStatus = ref.watch(connectivityStatusProvider);

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
                Expanded(
                  child: feedbackAsync.when(
                    loading: () =>
                        const GlobalLoader(message: 'Loading feedbacks info...'),
                    error: (error, stack) => GlobalError(
                      message: 'Failed to load feedbacks data: Try Again',
                      onRetry: () => ref.refresh(feedbackRepositoryProvider),
                    ),
                    data: (feedbacks) {
                      // Merge new feedback if it exists and isn't already in the list
                      // This is a simple handling to respect the 'newFeedback' parameter
                      // In a real app, this should probably be handled by a mutation + refresh
                      var displayFeedbacks = [...feedbacks];
                      if (widget.newFeedback != null &&
                          !displayFeedbacks.any(
                            (f) => f.id == widget.newFeedback!.id,
                          )) {
                        displayFeedbacks.insert(0, widget.newFeedback!);
                      }

                      // Filter by User ID if not admin
                      try {
                        if (!IsHaveAccess.instance.isAdmin) {
                          final currentUser = AuthManager.instance.currentUser;
                          if (currentUser != null) {
                            // Access id safely
                            // ignore: unnecessary_cast
                            final String? uid = (currentUser as dynamic).id?.toString();
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

                      final filteredFeedbacks = displayFeedbacks.where((
                        feedback,
                      ) {
                        if (searchQuery.isEmpty) return true;
                        final query = searchQuery.toLowerCase();
                        return feedback.name.toLowerCase().contains(query) ||
                            feedback.email.toLowerCase().contains(query) ||
                            feedback.message.toLowerCase().contains(query);
                      }).toList();

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsGeometry.symmetric(
                                  vertical: 8.0,
                                ),
                                child: CustomInputSearch(
                                  searchProvider: feedbackSearchQueryProvider,
                                  hint: "Search feedbacks",
                                ),
                              ),
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
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const GlobalLoader(message: 'Checking connection...'),
          error: (error, stack) => GlobalError(
            message: 'Failed to check connectivity: $error',
            onRetry: () => ref.invalidate(connectivityStatusProvider),
          ),
        ),
      ),
    );
  }
}
