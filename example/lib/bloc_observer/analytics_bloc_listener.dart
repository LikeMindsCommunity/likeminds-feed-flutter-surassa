import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';

void analyticsBlocListener(BuildContext context, LMAnalyticsState state) {
  debugPrint('inside handler');
  if (state is AnalyticsEventFired) {
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");

    debugPrint("\n\n\n\nAnalytics Event Fired: ${state.eventName}\n\n");
    state.eventProperties.forEach((key, value) {
      debugPrint("Key: $key, Value: $value");
    });

    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");
  }
}
