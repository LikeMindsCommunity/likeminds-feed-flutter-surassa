import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

void analyticsBlocListener(BuildContext context, LMFeedAnalyticsState state) {
  debugPrint('inside handler');
  if (state is LMFeedAnalyticsEventFired) {
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
