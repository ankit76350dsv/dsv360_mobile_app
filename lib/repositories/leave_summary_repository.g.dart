// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_summary_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$leaveSummaryRepositoryHash() =>
    r'714b6d28a5c9f92336fdf38e2054c8f74c5d6745';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$LeaveSummaryRepository
    extends BuildlessAsyncNotifier<LeaveSummary> {
  late final String userId;
  late final String username;

  FutureOr<LeaveSummary> build({
    required String userId,
    required String username,
  });
}

/// See also [LeaveSummaryRepository].
@ProviderFor(LeaveSummaryRepository)
const leaveSummaryRepositoryProvider = LeaveSummaryRepositoryFamily();

/// See also [LeaveSummaryRepository].
class LeaveSummaryRepositoryFamily extends Family<AsyncValue<LeaveSummary>> {
  /// See also [LeaveSummaryRepository].
  const LeaveSummaryRepositoryFamily();

  /// See also [LeaveSummaryRepository].
  LeaveSummaryRepositoryProvider call({
    required String userId,
    required String username,
  }) {
    return LeaveSummaryRepositoryProvider(userId: userId, username: username);
  }

  @override
  LeaveSummaryRepositoryProvider getProviderOverride(
    covariant LeaveSummaryRepositoryProvider provider,
  ) {
    return call(userId: provider.userId, username: provider.username);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'leaveSummaryRepositoryProvider';
}

/// See also [LeaveSummaryRepository].
class LeaveSummaryRepositoryProvider
    extends AsyncNotifierProviderImpl<LeaveSummaryRepository, LeaveSummary> {
  /// See also [LeaveSummaryRepository].
  LeaveSummaryRepositoryProvider({
    required String userId,
    required String username,
  }) : this._internal(
         () => LeaveSummaryRepository()
           ..userId = userId
           ..username = username,
         from: leaveSummaryRepositoryProvider,
         name: r'leaveSummaryRepositoryProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$leaveSummaryRepositoryHash,
         dependencies: LeaveSummaryRepositoryFamily._dependencies,
         allTransitiveDependencies:
             LeaveSummaryRepositoryFamily._allTransitiveDependencies,
         userId: userId,
         username: username,
       );

  LeaveSummaryRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.username,
  }) : super.internal();

  final String userId;
  final String username;

  @override
  FutureOr<LeaveSummary> runNotifierBuild(
    covariant LeaveSummaryRepository notifier,
  ) {
    return notifier.build(userId: userId, username: username);
  }

  @override
  Override overrideWith(LeaveSummaryRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: LeaveSummaryRepositoryProvider._internal(
        () => create()
          ..userId = userId
          ..username = username,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        username: username,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<LeaveSummaryRepository, LeaveSummary>
  createElement() {
    return _LeaveSummaryRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeaveSummaryRepositoryProvider &&
        other.userId == userId &&
        other.username == username;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LeaveSummaryRepositoryRef on AsyncNotifierProviderRef<LeaveSummary> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `username` of this provider.
  String get username;
}

class _LeaveSummaryRepositoryProviderElement
    extends AsyncNotifierProviderElement<LeaveSummaryRepository, LeaveSummary>
    with LeaveSummaryRepositoryRef {
  _LeaveSummaryRepositoryProviderElement(super.provider);

  @override
  String get userId => (origin as LeaveSummaryRepositoryProvider).userId;
  @override
  String get username => (origin as LeaveSummaryRepositoryProvider).username;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
