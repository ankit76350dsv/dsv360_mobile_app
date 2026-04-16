import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dsv360/features/issues/model/issue_model.dart';
import 'package:dsv360/features/issues/repository/create_issue_repository.dart';
import 'package:dsv360/features/issues/repository/delete_issue_repository.dart';
import 'package:dsv360/features/issues/repository/fetch_issues_repository.dart';
import 'package:dsv360/features/issues/repository/update_issue_repository.dart';

final fetchIssuesRepositoryProvider = Provider<FetchIssuesRepository>((ref) {
  return FetchIssuesRepository();
});

final createIssueRepositoryProvider = Provider<CreateIssueRepository>((ref) {
  return CreateIssueRepository();
});

final updateIssueRepositoryProvider = Provider<UpdateIssueRepository>((ref) {
  return UpdateIssueRepository();
});

final deleteIssueRepositoryProvider = Provider<DeleteIssueRepository>((ref) {
  return DeleteIssueRepository();
});

// Issue List Provider
final issueListProvider = FutureProvider.autoDispose<List<IssueModel>>((
  ref,
) async {
  final repository = ref.watch(fetchIssuesRepositoryProvider);
  return repository.fetchIssues();
});
