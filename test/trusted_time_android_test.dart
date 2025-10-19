import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trusted_time_android/serialized_time_signal.dart';
import 'package:trusted_time_android/trusted_time_android.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('trusted_time_android');
  final List<MethodCall> log = <MethodCall>[];

  void setUpSuccess() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'computeCurrentUnixEpochMillis':
              return 1234567890123;
            case 'getLatestTimeSignal':
              return {
                'acquisitionEstimatedErrorMillis': 100,
                'currentInstant': {
                  'estimatedErrorMillis': 150,
                  'instantMillis': 1234567890123,
                },
              };
            default:
              return null;
          }
        });
  }

  void setUpFailure() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });
  }

  setUp(() {
    log.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('TrustedTimeAndroid', () {
    test('instance returns the same instance', () {
      final instance1 = TrustedTimeAndroid.instance();
      final instance2 = TrustedTimeAndroid.instance();
      expect(instance1, same(instance2));
    });

    group('computeCurrentUnixEpochMillis', () {
      test('returns timestamp when available', () async {
        setUpSuccess();
        final trustedTime = TrustedTimeAndroid.instance();
        final result = await trustedTime.computeCurrentUnixEpochMillis();
        expect(result, 1234567890123);
        expect(log, hasLength(1));
        expect(log.single.method, 'computeCurrentUnixEpochMillis');
      });

      test('returns null when timestamp not available', () async {
        setUpFailure();
        final trustedTime = TrustedTimeAndroid.instance();
        final result = await trustedTime.computeCurrentUnixEpochMillis();
        expect(result, isNull);
        expect(log, hasLength(1));
        expect(log.single.method, 'computeCurrentUnixEpochMillis');
      });
    });

    group('getLatestTimeSignal', () {
      test('returns time signal when available', () async {
        setUpSuccess();
        final trustedTime = TrustedTimeAndroid.instance();
        final result = await trustedTime.getLatestTimeSignal();

        expect(result, isNotNull);
        expect(result!.acquisitionEstimatedErrorMillis, 100);
        expect(result.currentInstant, isNotNull);
        expect(result.currentInstant!.estimatedErrorMillis, 150);
        expect(result.currentInstant!.instantMillis, 1234567890123);

        expect(log, hasLength(1));
        expect(log.single.method, 'getLatestTimeSignal');
      });

      test('returns null when time signal not available', () async {
        setUpFailure();
        final trustedTime = TrustedTimeAndroid.instance();
        final result = await trustedTime.getLatestTimeSignal();
        expect(result, isNull);
        expect(log, hasLength(1));
        expect(log.single.method, 'getLatestTimeSignal');
      });
    });
  });

  group('SerializableTimeSignal', () {
    test('creates from map correctly', () {
      final map = {
        'acquisitionEstimatedErrorMillis': 100,
        'currentInstant': {
          'estimatedErrorMillis': 150,
          'instantMillis': 1234567890123,
        },
      };

      final signal = SerializableTimeSignal.fromMap(map);
      expect(signal.acquisitionEstimatedErrorMillis, 100);
      expect(signal.currentInstant, isNotNull);
      expect(signal.currentInstant!.estimatedErrorMillis, 150);
      expect(signal.currentInstant!.instantMillis, 1234567890123);
    });

    test('handles null currentInstant', () {
      final map = {
        'acquisitionEstimatedErrorMillis': 100,
        'currentInstant': null,
      };

      final signal = SerializableTimeSignal.fromMap(map);
      expect(signal.acquisitionEstimatedErrorMillis, 100);
      expect(signal.currentInstant, isNull);
    });

    test('equals and hashCode work correctly', () {
      const signal1 = SerializableTimeSignal(
        acquisitionEstimatedErrorMillis: 100,
        currentInstant: SerializableCurrentInstant(
          estimatedErrorMillis: 150,
          instantMillis: 1234567890123,
        ),
      );

      const signal2 = SerializableTimeSignal(
        acquisitionEstimatedErrorMillis: 100,
        currentInstant: SerializableCurrentInstant(
          estimatedErrorMillis: 150,
          instantMillis: 1234567890123,
        ),
      );

      expect(signal1, equals(signal2));
      expect(signal1.hashCode, equals(signal2.hashCode));
    });
  });

  group('SerializableCurrentInstant', () {
    test('creates from map correctly', () {
      final map = {'estimatedErrorMillis': 150, 'instantMillis': 1234567890123};

      final instant = SerializableCurrentInstant.fromMap(map);
      expect(instant.estimatedErrorMillis, 150);
      expect(instant.instantMillis, 1234567890123);
    });

    test('handles null values', () {
      final map = {'estimatedErrorMillis': null, 'instantMillis': null};

      final instant = SerializableCurrentInstant.fromMap(map);
      expect(instant.estimatedErrorMillis, isNull);
      expect(instant.instantMillis, isNull);
    });

    test('equals and hashCode work correctly', () {
      const instant1 = SerializableCurrentInstant(
        estimatedErrorMillis: 150,
        instantMillis: 1234567890123,
      );

      const instant2 = SerializableCurrentInstant(
        estimatedErrorMillis: 150,
        instantMillis: 1234567890123,
      );

      expect(instant1, equals(instant2));
      expect(instant1.hashCode, equals(instant2.hashCode));
    });
  });
}
