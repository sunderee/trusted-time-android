import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A Flutter plugin that provides access to Google Play Services' TrustedTime API,
/// offering reliable and accurate time keeping capabilities independent of device settings.
///
/// This plugin wraps the Android TrustedTimeClient to provide accurate timestamps that:
/// - Cannot be manipulated by changing device time settings
/// - Account for device clock drift
/// - Maintain synchronization with Google's time servers
///
/// Example usage:
/// ```dart
/// final trustedTime = TrustedTimeAndroid.instance();
/// final timestamp = await trustedTime.computeCurrentUnixEpochMillis();
/// if (timestamp != null) {
///   print('Current trusted timestamp: $timestamp');
/// } else {
///   print('Trusted time not available - device may not have synchronized yet');
/// }
/// ```
class TrustedTimeAndroid extends PlatformInterface {
  static const String _methodChannelName = "trusted_time_android";
  static const String _methodComputeCurrentUnixEpochMillis =
      "computeCurrentUnixEpochMillis";

  static final Object _token = Object();
  static TrustedTimeAndroid? _instance;

  /// Returns the singleton instance of [TrustedTimeAndroid].
  static TrustedTimeAndroid instance() => _instance ??= TrustedTimeAndroid._();

  final MethodChannel _channel;

  TrustedTimeAndroid._()
    : _channel = MethodChannel(_methodChannelName),
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
}
