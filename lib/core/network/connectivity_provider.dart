import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
Stream<List<ConnectivityResult>> connectivityStatus(ConnectivityStatusRef ref) {
  return Connectivity().onConnectivityChanged;
}

@riverpod
Future<List<ConnectivityResult>> checkConnectivity(CheckConnectivityRef ref) async {
  return await Connectivity().checkConnectivity();
}
