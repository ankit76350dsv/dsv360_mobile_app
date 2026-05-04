// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_tracker_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attendanceTrackerListRepositoryHash() =>
    r'0a88747c40705e18e08e02845a41e4c4ef389dd7';

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

abstract class _$AttendanceTrackerListRepository
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

/// See also [AttendanceTrackerListRepository].
@ProviderFor(AttendanceTrackerListRepository)
const attendanceTrackerListRepositoryProvider =
    AttendanceTrackerListRepositoryFamily();

/// See also [AttendanceTrackerListRepository].
class AttendanceTrackerListRepositoryFamily
    extends Family<AsyncValue<List<AttendanceDetail>>> {
  /// See also [AttendanceTrackerListRepository].
  const AttendanceTrackerListRepositoryFamily();

  /// See also [AttendanceTrackerListRepository].
  AttendanceTrackerListRepositoryProvider call({
    required String userId,
    required String startDate,
    required String endDate,
  }) {
    return AttendanceTrackerListRepositoryProvider(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  AttendanceTrackerListRepositoryProvider getProviderOverride(
    covariant AttendanceTrackerListRepositoryProvider provider,
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
  String? get name => r'attendanceTrackerListRepositoryProvider';
}

/// See also [AttendanceTrackerListRepository].
class AttendanceTrackerListRepositoryProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AttendanceTrackerListRepository,
          List<AttendanceDetail>
        > {
  /// See also [AttendanceTrackerListRepository].
  AttendanceTrackerListRepositoryProvider({
    required String userId,
    required String startDate,
    required String endDate,
  }) : this._internal(
         () => AttendanceTrackerListRepository()
           ..userId = userId
           ..startDate = startDate
           ..endDate = endDate,
         from: attendanceTrackerListRepositoryProvider,
         name: r'attendanceTrackerListRepositoryProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$attendanceTrackerListRepositoryHash,
         dependencies: AttendanceTrackerListRepositoryFamily._dependencies,
         allTransitiveDependencies:
             AttendanceTrackerListRepositoryFamily._allTransitiveDependencies,
         userId: userId,
         startDate: startDate,
         endDate: endDate,
       );

  AttendanceTrackerListRepositoryProvider._internal(
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
    covariant AttendanceTrackerListRepository notifier,
  ) {
    return notifier.build(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Override overrideWith(AttendanceTrackerListRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: AttendanceTrackerListRepositoryProvider._internal(
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
    AttendanceTrackerListRepository,
    List<AttendanceDetail>
  >
  createElement() {
    return _AttendanceTrackerListRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceTrackerListRepositoryProvider &&
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
mixin AttendanceTrackerListRepositoryRef
    on AutoDisposeAsyncNotifierProviderRef<List<AttendanceDetail>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `startDate` of this provider.
  String get startDate;

  /// The parameter `endDate` of this provider.
  String get endDate;
}

class _AttendanceTrackerListRepositoryProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AttendanceTrackerListRepository,
          List<AttendanceDetail>
        >
    with AttendanceTrackerListRepositoryRef {
  _AttendanceTrackerListRepositoryProviderElement(super.provider);

  @override
  String get userId =>
      (origin as AttendanceTrackerListRepositoryProvider).userId;
  @override
  String get startDate =>
      (origin as AttendanceTrackerListRepositoryProvider).startDate;
  @override
  String get endDate =>
      (origin as AttendanceTrackerListRepositoryProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
