import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dsv360/features/profile/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileViewModelProvider = Provider<ProfileViewModel>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return ProfileViewModel(repository);
});

class ProfileViewModel {
  final ProfileRepository _repository;

  ProfileViewModel(this._repository);

  Future<String> resolveUserId() {
    return _repository.resolveUserId();
  }

  Future<dynamic> fetchUserProfile(String userId) {
    return _repository.fetchUserProfile(userId);
  }

  Future<Response<dynamic>> uploadProfileImage({
    required String userId,
    required File croppedFile,
    required String filename,
  }) async {
    return _repository.uploadProfileImage(
      userId: userId,
      croppedFile: croppedFile,
      filename: filename,
    );
  }

  Future<Response<dynamic>> uploadBannerImage({
    required String userId,
    required String imagePath,
    required String filename,
  }) async {
    return _repository.uploadBannerImage(
      userId: userId,
      imagePath: imagePath,
      filename: filename,
    );
  }
}
