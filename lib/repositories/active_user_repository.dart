import 'package:dsv360/models/active_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Temporary Active User Repository (Mock)
/// Replace with AsyncNotifier when API is ready
final activeUserRepositoryProvider =
    FutureProvider<ActiveUser>((ref) async {
  // ⏳ Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  // ❌ Uncomment to test error state
  // throw Exception("Failed to load active user");

  return ActiveUser(
    id: "1",
    name: "Aman Jain",
    email: "aman@company.com",
    role: "Admin",
    isActive: true,
  );
});

