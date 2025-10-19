import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:trusted_time_android/serialized_time_signal.dart';

/// A Flutter plugin that provides access to Google Play Services' TrustedTime API,
/// offering reliable and accurate time keeping capabilities independent of device settings.
///
/// This plugin wraps the Android TrustedTimeClient to provide accurate timestamps that:
/// - Cannot be manipulated by changing device time settings
/// - Account for device clock drift
/// - Maintain synchronization with Google's time servers
///
/// The plugin offers two main methods:
/// 1. [computeCurrentUnixEpochMillis] - Get current timestamp
/// 2. [getLatestTimeSignal] - Get detailed time signal information including error estimates
///
/// Example usage:
/// ```dart
/// final trustedTime = TrustedTimeAndroid.instance();
///
/// // Basic timestamp retrieval
/// final timestamp = await trustedTime.computeCurrentUnixEpochMillis();
///
/// // Detailed time signal with error estimates
/// final signal = await trustedTime.getLatestTimeSignal();
/// if (signal?.currentInstant != null) {
///   print('Time: ${signal!.currentInstant!.instantMillis}');
///   print('Error margin: ±${signal.currentInstant!.estimatedErrorMillis}ms');
/// }
/// ```
class TrustedTimeAndroid extends PlatformInterface {
  static const String _methodChannelName = "trusted_time_android";
  static const String _methodComputeCurrentUnixEpochMillis =
      "computeCurrentUnixEpochMillis";
  static const String _methodGetLatestTimeSignal = "getLatestTimeSignal";

  static final Object _token = Object();
  static TrustedTimeAndroid? _instance;

  /// Returns the singleton instance of [TrustedTimeAndroid].
  static TrustedTimeAndroid instance() => _instance ??= TrustedTimeAndroid._();

  final MethodChannel _channel;

  TrustedTimeAndroid._()
    : _channel = const MethodChannel(_methodChannelName),
      super(token: _token);

  /// Retrieves the current time as milliseconds since Unix epoch from TrustedTime.
  ///
  /// Returns null if:
  /// - Device hasn't connected to the internet since last boot
  /// - Google Play Services is not available
  /// - Time signal hasn't been received yet
  ///
  /// The returned timestamp is guaranteed to be:
  /// - Independent of device time settings
  /// - Synchronized with Google's time servers
  /// - Accurate within the error bounds provided by the time signal
  Future<int?> computeCurrentUnixEpochMillis() =>
      _channel.invokeMethod<int>(_methodComputeCurrentUnixEpochMillis);

  /// Retrieves the latest time signal from TrustedTime API with detailed information
  /// about the time measurement, including error estimates.
  ///
  /// Returns null if:
  /// - Device hasn't connected to the internet since last boot
  /// - Google Play Services is not available
  /// - Time signal hasn't been received yet
  ///
  /// The [SerializableTimeSignal] contains:
  /// - [acquisitionEstimatedErrorMillis]: Error estimate for the initial time acquisition
  /// - [currentInstant]: Current time information including:
  ///   - [instantMillis]: The current timestamp
  ///   - [estimatedErrorMillis]: Current error estimate for the timestamp
  Future<SerializableTimeSignal?> getLatestTimeSignal() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      _methodGetLatestTimeSignal,
    );

    if (result != null) {
      return SerializableTimeSignal.fromMap(result);
    }

    return null;
  }
}
