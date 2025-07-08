import 'dart:math';

import '../lib/ascii_art.dart';
import '../lib/logger.dart';

void main() {
  printRandomAsciiArt();
  printQuote();
  logTime();
}

void printRandomAsciiArt() {
  final arts = [printCharizard1, printCharizard, printSnorlax, printSquirtle];

  final randomIndex = Random().nextInt(arts.length);
  arts[randomIndex]();
}
