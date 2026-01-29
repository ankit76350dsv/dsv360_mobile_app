import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/models/issue_model.dart';
import 'package:dsv360/repositories/issue_repository.dart';

// Repository Provider
final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return IssueRepository();
});

// Issue List Provider
final issueListProvider = FutureProvider.autoDispose<List<IssueModel>>((ref) async {
  final repository = ref.watch(issueRepositoryProvider);
  return repository.fetchIssues();
});
