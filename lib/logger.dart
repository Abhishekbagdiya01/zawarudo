import 'dart:io';
import 'time_calc.dart';
import 'ascii_art.dart';

const String logFilePath = 'logs/work_uptime_log.txt';
const double shiftHours = 9.0;

String color(String text, String code) => '\x1B[${code}m$text\x1B[0m';

Future<void> logTime() async {
  final now = DateTime.now();

  final todayStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final ampmHour = now.hour % 12 == 0 ? 12 : now.hour % 12;
  final ampmPeriod = now.hour >= 12 ? 'PM' : 'AM';
  final nowTime =
      '${ampmHour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $ampmPeriod';

  final bootTime = await getBootTime();
  final workedHoursToday = calculateWorkedHours(bootTime, now);

  final logFile = File(logFilePath);
  await logFile.parent.create(recursive: true);

  if (!await logFile.exists()) {
    await logFile.create();
  }

  final lines = await logFile.readAsLines();
  final todayIndex = lines.indexWhere((line) => line.startsWith(todayStr));

  if (todayIndex == -1) {
    final logLine =
        '$todayStr | login: $nowTime | logout: - | worked: - | shortfall: -';
    final existingLines = await logFile.readAsLines();
    existingLines.insert(0, logLine);
    await logFile.writeAsString(
      existingLines.join('\n') + '\n',
      mode: FileMode.write,
    );
    print(color("✨ logged login time: $nowTime ", '36')); // cyan
  } else {
    final parts = lines[todayIndex].split('|');
    final loginTime = parts[1].substring(parts[1].indexOf(':') + 1).trim();

    if (!loginTime.contains('AM') && !loginTime.contains('PM')) {
      try {
        final timeParts = loginTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final ampmHour = hour % 12 == 0 ? 12 : hour % 12;
        final ampmPeriod = hour >= 12 ? 'PM' : 'AM';
        final formattedLoginTime =
            '${ampmHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampmPeriod';
        parts[1] = ' login: $formattedLoginTime ';
      } catch (e) {}
    }

    final shortfall = shiftHours - workedHoursToday;
    final shortfallStr = shortfall.toStringAsFixed(2);
    final workedStr = workedHoursToday.toStringAsFixed(2);

    parts[2] = ' logout: $nowTime ';
    parts[3] = ' worked: ${workedStr}h ';
    parts[4] = ' shortfall: ${shortfallStr}h ';
    lines[todayIndex] = parts.join('|');
    await logFile.writeAsString(lines.join('\n') + '\n', mode: FileMode.write);

    print(color("✨ updated logout time: $nowTime ", '36')); // cyan
    print(color("🥰 worked so far today: ${workedStr}h", '33')); // yellow

    if (shortfall > 0) {
      print(color("🔥 shortfall: ${shortfallStr}h left to cover", '31')); // red
    } else {
      print(color("🎉 you covered your shift today ", '32')); // green
    }
  }
  await printMonthlyShortfall();
}

Future<void> printMonthlyShortfall() async {
  final now = DateTime.now();
  final currentMonth = now.month;
  final logFile = File(logFilePath);

  if (!await logFile.exists()) {
    return;
  }

  final lines = await logFile.readAsLines();
  double totalWorked = 0;
  double totalShortfall = 0;

  for (final line in lines) {
    final parts = line.split('|');
    if (parts.length < 5) continue;

    try {
      final dateParts = parts[0].trim().split('-');
      final month = int.parse(dateParts[1]);

      if (month == currentMonth) {
        final workedMatch = RegExp(r'worked: ([\d.]+)h').firstMatch(parts[3]);
        if (workedMatch != null) {
          totalWorked += double.parse(workedMatch.group(1)!);
        }

        final shortfallMatch = RegExp(
          r'shortfall: ([\d.]+)h',
        ).firstMatch(parts[4]);
        if (shortfallMatch != null) {
          totalShortfall += double.parse(shortfallMatch.group(1)!);
        }
      }
    } catch (e) {}
  }

  final totalWorkedStr = totalWorked.toStringAsFixed(2);
  final totalShortfallStr = totalShortfall.toStringAsFixed(2);

  print(color("\n--- Monthly Summary ---", '35')); // magenta
  print(
    color("✨ Total hours worked this month: ${totalWorkedStr}h", '33'),
  ); // yellow
  print(
    color("🔥 Total shortfall this month: ${totalShortfallStr}h", '31'),
  ); // red
  print(color("-----------------------\n", '35')); // magenta
  await printMonthlyLog();
}

Future<void> printMonthlyLog() async {
  final now = DateTime.now();
  final currentMonth = now.month;
  final logFile = File(logFilePath);

  if (!await logFile.exists()) {
    return;
  }

  final lines = await logFile.readAsLines();
  print(color("--- Monthly Log ---", '35')); // magenta

  for (final line in lines) {
    final parts = line.split('|');
    if (parts.length < 5) continue;

    try {
      final dateParts = parts[0].trim().split('-');
      final month = int.parse(dateParts[1]);

      if (month == currentMonth) {
        final date = parts[0].trim();
        final login = parts[1].trim();
        final logout = parts[2].trim();
        final worked = parts[3].trim();
        final shortfallPart = parts[4].trim();

        final shortfallMatch =
            RegExp(r'shortfall: ([-.\d]+)h').firstMatch(shortfallPart);
        var shortfallStr = shortfallPart;
        if (shortfallMatch != null) {
          final shortfall = double.parse(shortfallMatch.group(1)!);
          if (shortfall > 0) {
            shortfallStr = color(shortfallPart, '31'); // red
          } else {
            shortfallStr = color(shortfallPart, '32'); // green
          }
        }

        print(
            '$date | ${color(login, '36')} | ${color(logout, '36')} | ${color(worked, '33')} | $shortfallStr');
      }
    } catch (e) {}
  }
  print(color("-------------------\n", '35')); // magenta
}
