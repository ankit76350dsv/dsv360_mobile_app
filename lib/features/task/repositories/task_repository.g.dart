// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tasksListRepositoryHash() =>
    r'7e917368467e8d2ed6a2ae4486af7eae289a65f7';

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

abstract class _$TasksListRepository
    extends BuildlessAutoDisposeAsyncNotifier<List<Task>> {
  late final String userId;

  FutureOr<List<Task>> build(String userId);
}

/// See also [TasksListRepository].
@ProviderFor(TasksListRepository)
const tasksListRepositoryProvider = TasksListRepositoryFamily();

/// See also [TasksListRepository].
class TasksListRepositoryFamily extends Family<AsyncValue<List<Task>>> {
  /// See also [TasksListRepository].
  const TasksListRepositoryFamily();

  /// See also [TasksListRepository].
  TasksListRepositoryProvider call(String userId) {
    return TasksListRepositoryProvider(userId);
  }

  @override
  TasksListRepositoryProvider getProviderOverride(
    covariant TasksListRepositoryProvider provider,
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
  String? get name => r'tasksListRepositoryProvider';
}

/// See also [TasksListRepository].
class TasksListRepositoryProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<TasksListRepository, List<Task>> {
  /// See also [TasksListRepository].
  TasksListRepositoryProvider(String userId)
    : this._internal(
        () => TasksListRepository()..userId = userId,
        from: tasksListRepositoryProvider,
        name: r'tasksListRepositoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tasksListRepositoryHash,
        dependencies: TasksListRepositoryFamily._dependencies,
        allTransitiveDependencies:
            TasksListRepositoryFamily._allTransitiveDependencies,
        userId: userId,
      );

  TasksListRepositoryProvider._internal(
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
    covariant TasksListRepository notifier,
  ) {
    return notifier.build(userId);
  }

  @override
  Override overrideWith(TasksListRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: TasksListRepositoryProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<TasksListRepository, List<Task>>
  createElement() {
    return _TasksListRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksListRepositoryProvider && other.userId == userId;
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
mixin TasksListRepositoryRef
    on AutoDisposeAsyncNotifierProviderRef<List<Task>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _TasksListRepositoryProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<TasksListRepository, List<Task>>
    with TasksListRepositoryRef {
  _TasksListRepositoryProviderElement(super.provider);

  @override
  String get userId => (origin as TasksListRepositoryProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
