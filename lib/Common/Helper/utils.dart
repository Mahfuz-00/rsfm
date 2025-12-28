import 'dart:io';

String humanReadableFileSize(int bytes, [int decimals = 2]) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  final i = (bytes.bitLength - 1) ~/ 10;
  return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
}

String mkCmd(String url, String cmd) {
  return '$url?cmd=$cmd';
}