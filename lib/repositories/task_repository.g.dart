// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tasksByEmpOnlyHash() => r'b6fab780e847a90ef562c7dd81a17bb30f5c0c3e';

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

/// See also [tasksByEmpOnly].
@ProviderFor(tasksByEmpOnly)
const tasksByEmpOnlyProvider = TasksByEmpOnlyFamily();

/// See also [tasksByEmpOnly].
class TasksByEmpOnlyFamily extends Family<AsyncValue<List<Task>>> {
  /// See also [tasksByEmpOnly].
  const TasksByEmpOnlyFamily();

  /// See also [tasksByEmpOnly].
  TasksByEmpOnlyProvider call(String userId) {
    return TasksByEmpOnlyProvider(userId);
  }

  @override
  TasksByEmpOnlyProvider getProviderOverride(
    covariant TasksByEmpOnlyProvider provider,
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
  String? get name => r'tasksByEmpOnlyProvider';
}

/// See also [tasksByEmpOnly].
class TasksByEmpOnlyProvider extends AutoDisposeFutureProvider<List<Task>> {
  /// See also [tasksByEmpOnly].
  TasksByEmpOnlyProvider(String userId)
    : this._internal(
        (ref) => tasksByEmpOnly(ref as TasksByEmpOnlyRef, userId),
        from: tasksByEmpOnlyProvider,
        name: r'tasksByEmpOnlyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tasksByEmpOnlyHash,
        dependencies: TasksByEmpOnlyFamily._dependencies,
        allTransitiveDependencies:
            TasksByEmpOnlyFamily._allTransitiveDependencies,
        userId: userId,
      );

  TasksByEmpOnlyProvider._internal(
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
  Override overrideWith(
    FutureOr<List<Task>> Function(TasksByEmpOnlyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksByEmpOnlyProvider._internal(
        (ref) => create(ref as TasksByEmpOnlyRef),
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
  AutoDisposeFutureProviderElement<List<Task>> createElement() {
    return _TasksByEmpOnlyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksByEmpOnlyProvider && other.userId == userId;
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
mixin TasksByEmpOnlyRef on AutoDisposeFutureProviderRef<List<Task>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _TasksByEmpOnlyProviderElement
    extends AutoDisposeFutureProviderElement<List<Task>>
    with TasksByEmpOnlyRef {
  _TasksByEmpOnlyProviderElement(super.provider);

  @override
  String get userId => (origin as TasksByEmpOnlyProvider).userId;
}

String _$tasksListRepositoryHash() =>
    r'd18c0148a0371b996cbe42f241d9c1319b137fda';

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
