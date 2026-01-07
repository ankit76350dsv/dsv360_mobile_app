import 'package:dsv360/models/active_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserApiService {
  Future<ActiveUser> fetchActiveUser() async {
    // Example API call
    await Future.delayed(const Duration(seconds: 1));

    // ❌ Uncomment to test error state
    // throw Exception("Failed to load active user");

    // Replace with real HTTP call later
    return ActiveUser(
      id: "1",
      name: "Aman Jain",
      email: "aman@company.com",
      role: "Admin",
      isActive: true,
    );
  }
}


final activeUserRepositoryProvider =
    AsyncNotifierProvider<ActiveUserNotifier, ActiveUser>(
  ActiveUserNotifier.new,
);


class ActiveUserNotifier extends AsyncNotifier<ActiveUser> {
  final _api = UserApiService();

  @override
  Future<ActiveUser> build() async {
    // Called ONLY ONCE unless invalidated
    return _api.fetchActiveUser();
  }

  // Optional: refresh user manually
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_api.fetchActiveUser);
  }
}