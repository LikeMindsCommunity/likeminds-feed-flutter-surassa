import 'dart:math';

import 'package:timeago/timeago.dart';

class SSCustomMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'now';
  @override
  String aboutAMinute(int minutes) => '${minutes}m';
  @override
  String minutes(int minutes) => '${minutes}m';
  @override
  String aboutAnHour(int minutes) => '${minutes}m';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '${hours}h';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int days) => '${days}d';
  @override
  String months(int months) => '${months}mo';
  @override
  String aboutAYear(int year) => '${year}y';
  @override
  String years(int years) => '${years}y';
  @override
  String wordSeparator() => ' ';
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = ["b", "kb", "mb", "gb", "tb"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

// Returns file size in double in MBs
double getFileSizeInDouble(int bytes) {
  return (bytes / pow(1024, 2));
}
