import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import '../network/handlers/network_handler.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AppDioClient(tokenStorage).build();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkHandlerProvider = Provider<NetworkHandler>((ref) {
  return NetworkHandler(ref.watch(connectivityProvider));
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final handler = ref.watch(networkHandlerProvider);
  return handler.watchConnectivity();
});
