import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/feedback_model.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/feedback_card.dart';
import 'feedback_detail_screen.dart';

class FeedbacksScreen extends StatefulWidget {
  final FeedbackModel? newFeedback;

  const FeedbacksScreen({super.key, this.newFeedback});

  @override
  State<FeedbacksScreen> createState() => _FeedbacksScreenState();
}

class _FeedbacksScreenState extends State<FeedbacksScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FeedbackModel> _allFeedbacks = [];
  List<FeedbackModel> _filteredFeedbacks = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
    _searchController.addListener(() => _filterFeedbacks(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFeedbacks() {
    // Sample feedback data - In a real app, this would come from an API or database
    _allFeedbacks = [
      FeedbackModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        message: 'Great application! Very user-friendly and intuitive interface.',
        images: [],
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Reviewed',
      ),
      FeedbackModel(
        id: '2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        message: 'The project management features are excellent. Would love to see time tracking integration.',
        images: [],
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Pending',
      ),
      FeedbackModel(
        id: '3',
        name: 'Mike Johnson',
        email: 'mike@example.com',
        message: 'Found a bug in the export functionality. Please check the CSV export feature.',
        images: [],
        date: DateTime.now(),
        status: 'In Review',
      ),
      FeedbackModel(
        id: '4',
        name: 'Sarah Wilson',
        email: 'sarah@example.com',
        message: 'Love the dark theme! Makes it easier on the eyes during late night work sessions.',
        images: [],
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Reviewed',
      ),
    ];
    
    // Add new feedback if provided
    if (widget.newFeedback != null) {
      _allFeedbacks.insert(0, widget.newFeedback!);
    }
    
    _filteredFeedbacks = _allFeedbacks;
  }

  void _filterFeedbacks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFeedbacks = _allFeedbacks;
      } else {
        _filteredFeedbacks = _allFeedbacks
            .where((feedback) =>
                feedback.name.toLowerCase().contains(query.toLowerCase()) ||
                feedback.email.toLowerCase().contains(query.toLowerCase()) ||
                feedback.message.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Feedbacks'),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Feedbacks',
                  //   style: TextStyle(
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.bold,
                  //     color: AppColors.textPrimary,
                  //   ),
                  // ),
                  // SizedBox(height: 8),
                  Text(
                    'Manage and review all customer feedbacks',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Search Feedbacks',
                onChanged: _filterFeedbacks,
              ),
              const SizedBox(height: 24),

              // Feedback Count
              Text(
                '${_filteredFeedbacks.length} Feedback${_filteredFeedbacks.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Feedbacks List
              if (_filteredFeedbacks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No feedbacks found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: _filteredFeedbacks
                      .map((feedback) => GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeedbackDetailScreen(feedback: feedback),
                                ),
                              );
                            },
                            child: FeedbackCard(feedback: feedback),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
