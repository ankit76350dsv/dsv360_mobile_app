// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_tasks_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingTasksListRepositoryHash() =>
    r'797c9eef3329b92d0de3f2dfaf8bf6451d327dcd';

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

abstract class _$PendingTasksListRepository
    extends BuildlessAutoDisposeAsyncNotifier<List<Task>> {
  late final String userId;

  FutureOr<List<Task>> build(String userId);
}

/// See also [PendingTasksListRepository].
@ProviderFor(PendingTasksListRepository)
const pendingTasksListRepositoryProvider = PendingTasksListRepositoryFamily();

/// See also [PendingTasksListRepository].
class PendingTasksListRepositoryFamily extends Family<AsyncValue<List<Task>>> {
  /// See also [PendingTasksListRepository].
  const PendingTasksListRepositoryFamily();

  /// See also [PendingTasksListRepository].
  PendingTasksListRepositoryProvider call(String userId) {
    return PendingTasksListRepositoryProvider(userId);
  }

  @override
  PendingTasksListRepositoryProvider getProviderOverride(
    covariant PendingTasksListRepositoryProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pendingTasksListRepositoryProvider';
}

/// See also [PendingTasksListRepository].
class PendingTasksListRepositoryProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PendingTasksListRepository,
          List<Task>
        > {
  /// See also [PendingTasksListRepository].
  PendingTasksListRepositoryProvider(String userId)
    : this._internal(
        () => PendingTasksListRepository()..userId = userId,
        from: pendingTasksListRepositoryProvider,
        name: r'pendingTasksListRepositoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pendingTasksListRepositoryHash,
        dependencies: PendingTasksListRepositoryFamily._dependencies,
        allTransitiveDependencies:
            PendingTasksListRepositoryFamily._allTransitiveDependencies,
        userId: userId,
      );

  PendingTasksListRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  FutureOr<List<Task>> runNotifierBuild(
    covariant PendingTasksListRepository notifier,
  ) {
    return notifier.build(userId);
  }

  @override
  Override overrideWith(PendingTasksListRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: PendingTasksListRepositoryProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    PendingTasksListRepository,
    List<Task>
  >
  createElement() {
    return _PendingTasksListRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PendingTasksListRepositoryProvider &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PendingTasksListRepositoryRef
    on AutoDisposeAsyncNotifierProviderRef<List<Task>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _PendingTasksListRepositoryProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PendingTasksListRepository,
          List<Task>
        >
    with PendingTasksListRepositoryRef {
  _PendingTasksListRepositoryProviderElement(super.provider);

  @override
  String get userId => (origin as PendingTasksListRepositoryProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
