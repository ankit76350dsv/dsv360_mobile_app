// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_logs_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timeLogsRepositoryHash() =>
    r'849aeaa0a5630e646c70c93f2828c31b3b37191a';

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

abstract class _$TimeLogsRepository
    extends BuildlessAutoDisposeAsyncNotifier<List<AttendanceDetail>> {
  late final String userId;
  late final String startDate;
  late final String endDate;

  FutureOr<List<AttendanceDetail>> build({
    required String userId,
    required String startDate,
    required String endDate,
  });
}

/// See also [TimeLogsRepository].
@ProviderFor(TimeLogsRepository)
const timeLogsRepositoryProvider = TimeLogsRepositoryFamily();

/// See also [TimeLogsRepository].
class TimeLogsRepositoryFamily
    extends Family<AsyncValue<List<AttendanceDetail>>> {
  /// See also [TimeLogsRepository].
  const TimeLogsRepositoryFamily();

  /// See also [TimeLogsRepository].
  TimeLogsRepositoryProvider call({
    required String userId,
    required String startDate,
    required String endDate,
  }) {
    return TimeLogsRepositoryProvider(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  TimeLogsRepositoryProvider getProviderOverride(
    covariant TimeLogsRepositoryProvider provider,
  ) {
    return call(
      userId: provider.userId,
      startDate: provider.startDate,
      endDate: provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timeLogsRepositoryProvider';
}

/// See also [TimeLogsRepository].
class TimeLogsRepositoryProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          TimeLogsRepository,
          List<AttendanceDetail>
        > {
  /// See also [TimeLogsRepository].
  TimeLogsRepositoryProvider({
    required String userId,
    required String startDate,
    required String endDate,
  }) : this._internal(
         () => TimeLogsRepository()
           ..userId = userId
           ..startDate = startDate
           ..endDate = endDate,
         from: timeLogsRepositoryProvider,
         name: r'timeLogsRepositoryProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$timeLogsRepositoryHash,
         dependencies: TimeLogsRepositoryFamily._dependencies,
         allTransitiveDependencies:
             TimeLogsRepositoryFamily._allTransitiveDependencies,
         userId: userId,
         startDate: startDate,
         endDate: endDate,
       );

  TimeLogsRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String userId;
  final String startDate;
  final String endDate;

  @override
  FutureOr<List<AttendanceDetail>> runNotifierBuild(
    covariant TimeLogsRepository notifier,
  ) {
    return notifier.build(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Override overrideWith(TimeLogsRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: TimeLogsRepositoryProvider._internal(
        () => create()
          ..userId = userId
          ..startDate = startDate
          ..endDate = endDate,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    TimeLogsRepository,
    List<AttendanceDetail>
  >
  createElement() {
    return _TimeLogsRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeLogsRepositoryProvider &&
        other.userId == userId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimeLogsRepositoryRef
    on AutoDisposeAsyncNotifierProviderRef<List<AttendanceDetail>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `startDate` of this provider.
  String get startDate;

  /// The parameter `endDate` of this provider.
  String get endDate;
}

class _TimeLogsRepositoryProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          TimeLogsRepository,
          List<AttendanceDetail>
        >
    with TimeLogsRepositoryRef {
  _TimeLogsRepositoryProviderElement(super.provider);

  @override
  String get userId => (origin as TimeLogsRepositoryProvider).userId;
  @override
  String get startDate => (origin as TimeLogsRepositoryProvider).startDate;
  @override
  String get endDate => (origin as TimeLogsRepositoryProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
