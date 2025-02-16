import 'package:flutter/material.dart';
import 'package:trusted_time_android/serialized_time_signal.dart';
import 'package:trusted_time_android/trusted_time_android.dart';

void main() => runApp(const App());

final class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

final class _AppState extends State<App> {
  int? _currentUnixEpochMillis;
  SerializableTimeSignal? _timeSignal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Trusted Time Android')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text(_currentUnixEpochMillis?.toString() ?? '-'),
                subtitle: Text('Current UNIX epoch (milliseconds)'),
                trailing: IconButton(
                  onPressed: () {
                    TrustedTimeAndroid.instance()
                        .computeCurrentUnixEpochMillis()
                        .then(
                          (value) =>
                              setState(() => _currentUnixEpochMillis = value),
                        );
                  },
                  icon: Icon(Icons.refresh),
                ),
              ),
              ListTile(
                title: Text(_timeSignal?.toString() ?? '-'),
                subtitle: Text('Latest time signal'),
                trailing: IconButton(
                  onPressed: () {
                    TrustedTimeAndroid.instance().getLatestTimeSignal().then(
                      (value) => setState(() => _timeSignal = value),
                    );
                  },
                  icon: Icon(Icons.refresh),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
