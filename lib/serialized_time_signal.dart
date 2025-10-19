/// Represents a serializable time signal from the TrustedTime API, containing
/// information about time measurement accuracy and current time.
///
/// This class includes:
/// - Initial time acquisition error estimates
/// - Current time information with error bounds
/// - Null safety for scenarios where time data is unavailable
final class SerializableTimeSignal {
  /// The estimated error (in milliseconds) for the initial time acquisition from
  /// Google's time servers. This represents the uncertainty in the initial
  /// synchronization process.
  ///
  /// This value is always available when a time signal is received and represents
  /// the base accuracy of the time synchronization.
  final int acquisitionEstimatedErrorMillis;

  /// Detailed information about the current time instant, including the timestamp
  /// and its error estimate. May be null if current time computation fails or
  /// if the time signal is too old.
  ///
  /// See [SerializableCurrentInstant] for more details about the current time information.
  final SerializableCurrentInstant? currentInstant;

  /// Creates a new [SerializableTimeSignal] instance.
  ///
  /// [acquisitionEstimatedErrorMillis] is required and represents the initial
  /// synchronization error estimate.
  /// [currentInstant] is optional and may be null if current time data is unavailable.
  const SerializableTimeSignal({
    required this.acquisitionEstimatedErrorMillis,
    this.currentInstant,
  });

  /// Creates a [SerializableTimeSignal] from a map structure, typically received
  /// from the platform-specific code.
  ///
  /// The map must contain:
  /// - 'acquisitionEstimatedErrorMillis' as an integer
  /// - Optional 'currentInstant' as a map that can be parsed by [SerializableCurrentInstant.fromMap]
  factory SerializableTimeSignal.fromMap(Map<Object?, Object?> map) {
    return SerializableTimeSignal(
      acquisitionEstimatedErrorMillis:
          map['acquisitionEstimatedErrorMillis'] as int,
      currentInstant: map['currentInstant'] != null
          ? SerializableCurrentInstant.fromMap(
              map['currentInstant'] as Map<Object?, Object?>,
            )
          : null,
    );
  }

  @override
  int get hashCode =>
      acquisitionEstimatedErrorMillis.hashCode ^ currentInstant.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SerializableTimeSignal &&
        other.acquisitionEstimatedErrorMillis ==
            acquisitionEstimatedErrorMillis &&
        other.currentInstant == currentInstant;
  }

  @override
  String toString() {
    return 'SerializableTimeSignal(acquisitionEstimatedErrorMillis: $acquisitionEstimatedErrorMillis, currentInstant: $currentInstant)';
  }
}

/// Represents a specific time instant from the TrustedTime API, including
/// the timestamp and its error estimate.
///
/// This class provides:
/// - The actual timestamp in milliseconds since Unix epoch
/// - The estimated error margin for this timestamp
/// - Null safety for both values in case of unavailability
final class SerializableCurrentInstant {
  /// The estimated error (in milliseconds) for the current timestamp.
  /// May be null if error estimation fails.
  ///
  /// This value represents the current uncertainty in the time measurement,
  /// which may increase as time passes since the last synchronization.
  final int? estimatedErrorMillis;

  /// The current timestamp in milliseconds since Unix epoch.
  /// May be null if time computation fails.
  ///
  /// This timestamp is guaranteed to be:
  /// - Independent of device time settings
  /// - Synchronized with Google's time servers
  /// - Accurate within [estimatedErrorMillis] bounds
  final int? instantMillis;

  /// Creates a new [SerializableCurrentInstant] instance.
  ///
  /// Both [estimatedErrorMillis] and [instantMillis] are optional and may be null
  /// if the respective data is unavailable.
  const SerializableCurrentInstant({
    this.estimatedErrorMillis,
    this.instantMillis,
  });

  /// Creates a [SerializableCurrentInstant] from a map structure, typically
  /// received from the platform-specific code.
  ///
  /// The map may contain:
  /// - 'estimatedErrorMillis' as an optional integer
  /// - 'instantMillis' as an optional integer
  factory SerializableCurrentInstant.fromMap(Map<Object?, Object?> map) {
    return SerializableCurrentInstant(
      estimatedErrorMillis: map['estimatedErrorMillis'] as int?,
      instantMillis: map['instantMillis'] as int?,
    );
  }

  @override
  int get hashCode => estimatedErrorMillis.hashCode ^ instantMillis.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SerializableCurrentInstant &&
        other.estimatedErrorMillis == estimatedErrorMillis &&
        other.instantMillis == instantMillis;
  }

  @override
  String toString() {
    return 'SerializableCurrentInstant(estimatedErrorMillis: $estimatedErrorMillis, instantMillis: $instantMillis)';
  }
}
