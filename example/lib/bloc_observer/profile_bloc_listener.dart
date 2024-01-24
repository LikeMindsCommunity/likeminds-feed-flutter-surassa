import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

void profileBlocListener(BuildContext context, LMFeedProfileState state) {
  if (state is LMFeedLoginRequiredState) {
    // TODO: Implement LoginRequired
  } else if (state is LMFeedLogoutState) {
    // TODO: Implement Logout
  } else if (state is LMFeedRouteToCompanyProfileState) {
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("\n\nCompany ID caught in callback : ${state.companyId}\n\n");
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");
  } else if (state is LMFeedRouteToUserProfileState) {
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("\n\nUser ID caught in callback : ${state.userUniqueId}\n\n");
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");
  }
}
