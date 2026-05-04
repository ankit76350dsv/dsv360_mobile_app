import 'package:dsv360/models/active_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeUserRepositoryProvider =
    NotifierProvider<ActiveUserRepository, ActiveUserModel?>(
  ActiveUserRepository.new,
);

class ActiveUserRepository extends Notifier<ActiveUserModel?> {
  @override
  ActiveUserModel? build() => null;

  void setUser(ActiveUserModel user) {
    state = user;
  }

  void updateUser(ActiveUserModel user) {
    state = user;
  }

  void clear() {
    state = null;
  }
}
