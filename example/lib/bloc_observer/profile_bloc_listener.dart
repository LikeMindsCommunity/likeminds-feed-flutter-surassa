import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';

void profileBlocListener(BuildContext context, LMProfileState state) {
  if (state is LoginRequiredState) {
    // TODO: Implement LoginRequired
  } else if (state is LogoutState) {
    // TODO: Implement Logout
  } else if (state is RouteToCompanyProfileState) {
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("\n\nCompany ID caught in callback : ${state.companyId}\n\n");
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");
  } else if (state is RouteToUserProfileState) {
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("\n\nUser ID caught in callback : ${state.userUniqueId}\n\n");
    debugPrint("///////////////////////////////////////////////////////");
    debugPrint("///////////////////////////////////////////////////////");
  }
}
