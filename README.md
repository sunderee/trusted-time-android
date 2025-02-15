# trusted_time_android

A Flutter plugin providing reliable and accurate time keeping for Android apps using Google's TrustedTime API. This plugin offers timestamps that are independent of device settings and synchronized with Google's time servers.

**This is the first version of the plugin, and it only supports `computeCurrentUnixEpochMillis` method. Not ready for production use.**

## Features

- Reliable timestamps independent of device time settings
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
  trusted_time_android: ^0.0.1
```

## Usage

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

## Important Notes

1. **First Boot Synchronization**: After device boot, the TrustedTime API requires an initial internet connection to synchronize. Until this happens, timestamps will return null.

2. **Google Play Services**: This plugin requires Google Play Services. It will not work on devices without Google Play Services (like some Huawei devices).

3. **Error Handling**: Always check for null returns, which indicate that a trusted timestamp is not available.

4. **Battery & Network Impact**: The API is designed to be efficient, using periodic synchronization rather than constant network requests.

## Common Issues

- **Null Timestamps**: If `computeCurrentUnixEpochMillis()` returns null, check:
  - Internet connectivity
  - Google Play Services availability
  - Whether the device has booted recently without network access

- **Accuracy**: While highly accurate, timestamps may have some error margin due to:
  - Network latency during synchronization
  - Time elapsed since last sync
  - Device clock drift

## License

Project is licensed under the MIT license. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.