import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';

void routingBlocListener(BuildContext context, LMRoutingState state) {
  if (state is OpenPostNotification) {
    // TODO: Navigate to Post Details Screen;
  } else if (state is OpenSharedPost) {
    // TODO: Navigate to Post Details Screen;
  } else if (state is ErrorPostNotification) {
    // TODO: Handle post notification error
  } else if (state is ErrorSharedPost) {
    // TODO: Handle share post error
  }
}
