// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_list_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attendanceDetailListRepositoryHash() =>
    r'0dd6925e62d6cbd80d22e11fa79179688cd5f77d';

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

abstract class _$AttendanceDetailListRepository
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

/// See also [AttendanceDetailListRepository].
@ProviderFor(AttendanceDetailListRepository)
const attendanceDetailListRepositoryProvider =
    AttendanceDetailListRepositoryFamily();

/// See also [AttendanceDetailListRepository].
class AttendanceDetailListRepositoryFamily
    extends Family<AsyncValue<List<AttendanceDetail>>> {
  /// See also [AttendanceDetailListRepository].
  const AttendanceDetailListRepositoryFamily();

  /// See also [AttendanceDetailListRepository].
  AttendanceDetailListRepositoryProvider call({
    required String userId,
    required String startDate,
    required String endDate,
  }) {
    return AttendanceDetailListRepositoryProvider(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  AttendanceDetailListRepositoryProvider getProviderOverride(
    covariant AttendanceDetailListRepositoryProvider provider,
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
  String? get name => r'attendanceDetailListRepositoryProvider';
}

/// See also [AttendanceDetailListRepository].
class AttendanceDetailListRepositoryProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AttendanceDetailListRepository,
          List<AttendanceDetail>
        > {
  /// See also [AttendanceDetailListRepository].
  AttendanceDetailListRepositoryProvider({
    required String userId,
    required String startDate,
    required String endDate,
  }) : this._internal(
         () => AttendanceDetailListRepository()
           ..userId = userId
           ..startDate = startDate
           ..endDate = endDate,
         from: attendanceDetailListRepositoryProvider,
         name: r'attendanceDetailListRepositoryProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$attendanceDetailListRepositoryHash,
         dependencies: AttendanceDetailListRepositoryFamily._dependencies,
         allTransitiveDependencies:
             AttendanceDetailListRepositoryFamily._allTransitiveDependencies,
         userId: userId,
         startDate: startDate,
         endDate: endDate,
       );

  AttendanceDetailListRepositoryProvider._internal(
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
    covariant AttendanceDetailListRepository notifier,
  ) {
    return notifier.build(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Override overrideWith(AttendanceDetailListRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: AttendanceDetailListRepositoryProvider._internal(
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
    AttendanceDetailListRepository,
    List<AttendanceDetail>
  >
  createElement() {
    return _AttendanceDetailListRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceDetailListRepositoryProvider &&
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
mixin AttendanceDetailListRepositoryRef
    on AutoDisposeAsyncNotifierProviderRef<List<AttendanceDetail>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `startDate` of this provider.
  String get startDate;

  /// The parameter `endDate` of this provider.
  String get endDate;
}

class _AttendanceDetailListRepositoryProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AttendanceDetailListRepository,
          List<AttendanceDetail>
        >
    with AttendanceDetailListRepositoryRef {
  _AttendanceDetailListRepositoryProviderElement(super.provider);

  @override
  String get userId =>
      (origin as AttendanceDetailListRepositoryProvider).userId;
  @override
  String get startDate =>
      (origin as AttendanceDetailListRepositoryProvider).startDate;
  @override
  String get endDate =>
      (origin as AttendanceDetailListRepositoryProvider).endDate;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
