import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelpers {
  static final Connectivity _connectivity = Connectivity();

  // Check if device is connected to internet
  static Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty && !results.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  // Stream of connectivity changes
  static Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.isNotEmpty && !results.contains(ConnectivityResult.none);
    });
  }

  // Retry function with exponential backoff
  static Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow;
        }

        await Future.delayed(delay);
        delay *= backoffMultiplier;
      }
    }
  }

  // Execute operation with timeout
  static Future<T> withTimeout<T>(
    Future<T> Function() operation,
    Duration timeout,
  ) async {
    return await operation().timeout(
      timeout,
      onTimeout: () {
        throw TimeoutException('Operation timed out after ${timeout.inSeconds}s');
      },
    );
  }

  // Check if URL is reachable
  static Future<bool> isUrlReachable(String url) async {
    try {
      // This would typically use http package to check
      // For now, just check connectivity
      return await isConnected();
    } catch (e) {
      return false;
    }
  }

  // Get connection type
  static Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return 'None';
      }
      
      final result = results.first;
      switch (result) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Mobile Data';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.vpn:
          return 'VPN';
        default:
          return 'Other';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // Check if connection is metered (mobile data)
  static Future<bool> isMeteredConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
