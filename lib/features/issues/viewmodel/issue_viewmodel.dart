import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/issues/model/issue_model.dart';
import 'package:dsv360/features/issues/repository/issue_repository.dart';

final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return IssueRepository();
});

// Legacy aliases kept for existing consumers.
final fetchIssuesRepositoryProvider = Provider<IssueRepository>((ref) => ref.read(issueRepositoryProvider));
final createIssueRepositoryProvider = Provider<IssueRepository>((ref) => ref.read(issueRepositoryProvider));
final updateIssueRepositoryProvider = Provider<IssueRepository>((ref) => ref.read(issueRepositoryProvider));
final deleteIssueRepositoryProvider = Provider<IssueRepository>((ref) => ref.read(issueRepositoryProvider));

final issueListProvider = FutureProvider.autoDispose<List<IssueModel>>((ref) async {
  return ref.watch(issueRepositoryProvider).fetchIssues();
});
