import 'package:flutter_riverpod/flutter_riverpod.dart';

// Search query for leave list filtering
final leaveSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// Selected leave type filter (null = All)
final leaveTypeFilterProvider = StateProvider.autoDispose<String?>((ref) => null);

const List<String> leaveTypeOptions = [
  'Paid Leave',
  'Sick Leave',
  'Unpaid Leave',
];
