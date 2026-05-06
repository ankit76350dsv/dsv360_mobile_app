import 'package:dsv360/features/sprints/repositories/heirarchy_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hierarchyRepositoryProvider = Provider<HierarchyRepository>((ref) {
  return HierarchyRepository();
});
