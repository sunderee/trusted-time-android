# trusted_time_android

A Flutter plugin providing reliable and accurate time keeping for Android apps using Google's TrustedTime API. This plugin offers timestamps that are independent of device settings and synchronized with Google's time servers.

## Features

- Reliable timestamps independent of device time settings
- Detailed error estimates for time measurements
- Accounts for device clock drift
- Maintains synchronization with Google's time servers
- Handles offline scenarios gracefully
- Minimal battery and network impact

## Prerequisites

- Android 5.0 (API level 21) or higher
- Google Play Services installed and up-to-date
- `com.google.android.gms:play-services-time:16.0.1` or higher

## Installation

```yaml
dependencies:
  trusted_time_android: ^0.0.2
```

## Usage

### Basic Timestamp Retrieval

```dart
import 'package:trusted_time_android/trusted_time_android.dart';

// Get the singleton instance
final trustedTime = TrustedTimeAndroid.instance();

// Get current timestamp
final timestamp = await trustedTime.computeCurrentUnixEpochMillis();
if (timestamp != null) {
  print('Current trusted timestamp: $timestamp');
} else {
  print('Trusted time not available');
}
```

### Detailed Time Signal Information

```dart
// Get detailed time signal with error estimates
final signal = await trustedTime.getLatestTimeSignal();
if (signal?.currentInstant != null) {
  final instant = signal!.currentInstant!;
  print('Current time: ${instant.instantMillis}');
  print('Measurement error: ±${instant.estimatedErrorMillis}ms');
  print('Initial acquisition error: ±${signal.acquisitionEstimatedErrorMillis}ms');
}
```

## Important Notes

1. **First Boot Synchronization**: After device boot, the TrustedTime API requires an initial internet connection to synchronize. Until this happens, timestamps will return null.

2. **Google Play Services**: This plugin requires Google Play Services. It will not work on devices without Google Play Services (like some Huawei devices).

3. **Error Handling**: Always check for null returns, which indicate that a trusted timestamp is not available.

4. **Error Estimates**: The API provides error estimates for time measurements:
   - `estimatedErrorMillis`: Current error margin for the timestamp
   - `acquisitionEstimatedErrorMillis`: Error margin from initial time acquisition

5. **Battery & Network Impact**: The API is designed to be efficient, using periodic synchronization rather than constant network requests.

## Common Issues

- **Null Timestamps**: If methods return null, check:
  - Internet connectivity
  - Google Play Services availability
  - Whether the device has booted recently without network access

- **Accuracy Considerations**: 
  - Error estimates provide bounds for timestamp accuracy
  - Network latency affects initial synchronization
  - Time elapsed since last sync impacts accuracy
  - Device clock drift is automatically compensated

## Error Handling Best Practices

```dart
final signal = await trustedTime.getLatestTimeSignal();
if (signal == null) {
  print('Time signal not available');
  return;
}

final instant = signal.currentInstant;
if (instant == null) {
  print('Current time information not available');
  return;
}

if (instant.estimatedErrorMillis != null && 
    instant.estimatedErrorMillis! > 1000) {
  print('Warning: Time measurement has high error margin');
}

print('Time: ${instant.instantMillis}');
print('Error margin: ±${instant.estimatedErrorMillis}ms');
```

## License

Project is licensed under the MIT license. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.