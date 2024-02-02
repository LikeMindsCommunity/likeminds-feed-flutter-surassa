import 'package:likeminds_feed_ss_fl/app.dart';
import 'package:intl/intl.dart';

/// English short Messages
class SuraasaCustomTimeStamps implements LMFeedTimeAgoMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds, DateTime dateTime) => 'now';
  @override
  String aboutAMinute(DateTime dateTime) => '1m';
  @override
  String minutes(int minutes, DateTime dateTime) => '${minutes}m';
  @override
  String aboutAnHour(DateTime dateTime) => '1h';
  @override
  String hours(int hours, DateTime dateTime) => '${hours}h';
  @override
  String aDay(DateTime dateTime) => '1d';
  @override
  String days(int days, DateTime dateTime) => '${days}d';
  @override
  String aboutAMonth(DateTime dateTime) => getFormattedMonthOlder(dateTime);
  @override
  String months(int months, DateTime dateTime) =>
      getFormattedMonthOlder(dateTime);
  @override
  String aboutAYear(DateTime dateTime) => getFormattedMonthOlder(dateTime);
  @override
  String years(int years, DateTime dateTime) =>
      getFormattedMonthOlder(dateTime);
  @override
  String wordSeparator() => ' ';
}

String getFormattedMonthOlder(DateTime dateTime) {
  DateTime currentTime = DateTime.now();

  if (dateTime.year != currentTime.year) {
    DateFormat formatter = DateFormat('d MMM yyyy');

    return formatter.format(dateTime);
  } else {
    DateFormat formatter = DateFormat('d MMM');

    return formatter.format(dateTime);
  }
}
