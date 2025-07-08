import 'dart:io';

/// Gets the boot time based on the operating system.
Future<DateTime> getBootTime() async {
  if (Platform.isLinux) {
    return await getBootTimeLinux();
  } else if (Platform.isMacOS) {
    return await getBootTimeMac();
  } else {
    throw Exception(
      'Unsupported operating system: ${Platform.operatingSystem}',
    );
  }
}

/// Reads system boot time on Linux by running `uptime -s`
Future<DateTime> getBootTimeLinux() async {
  final result = await Process.run('uptime', ['-s']);

  if (result.exitCode != 0) {
    throw Exception("Failed to get boot time: ${result.stderr}");
  }

  final bootTimeStr = result.stdout.toString().trim();
  return DateTime.parse(bootTimeStr);
}

/// Reads system boot time on macOS by parsing `sysctl -n kern.boottime`
Future<DateTime> getBootTimeMac() async {
  final result = await Process.run('sysctl', ['-n', 'kern.boottime']);

  if (result.exitCode != 0) {
    throw Exception("Failed to get boot time: ${result.stderr}");
  }

  final output = result.stdout.toString();
  final match = RegExp(r'sec = (\d+),').firstMatch(output);

  if (match == null) {
    throw Exception("Could not parse macOS boot time.");
  }

  final secondsSinceEpoch = int.parse(match.group(1)!);
  return DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);
}

/// Calculate worked hours today given boot time & now
double calculateWorkedHours(DateTime bootTime, DateTime now) {
  final workedDuration = now.difference(bootTime);
  return double.parse((workedDuration.inMinutes / 60).toStringAsFixed(2));
}
