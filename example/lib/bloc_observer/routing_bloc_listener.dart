import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

void routingBlocListener(BuildContext context, LMFeedRoutingState state) {
  if (state is LMFeedOpenPostNotificationState) {
    // TODO: Navigate to Post Details Screen;
  } else if (state is LMFeedOpenSharedPostState) {
    // TODO: Navigate to Post Details Screen;
  } else if (state is LMFeedErrorPostNotificationState) {
    // TODO: Handle post notification error
  } else if (state is LMFeedErrorSharedPostState) {
    // TODO: Handle share post error
  }
}
