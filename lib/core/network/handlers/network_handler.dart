import 'package:connectivity_plus/connectivity_plus.dart';

final class NetworkHandler {
  NetworkHandler(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Stream<bool> watchConnectivity() {
    return _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );
  }
}
