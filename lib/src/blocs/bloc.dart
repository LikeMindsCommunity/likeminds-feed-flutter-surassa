// Events
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/post_bloc/post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/profile_bloc/profile_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/routing_bloc/routing_bloc.dart';

export 'package:likeminds_feed_ss_fl/src/blocs/analytics_bloc/analytics_bloc.dart';
export 'package:likeminds_feed_ss_fl/src/blocs/post_bloc/post_bloc.dart';
export 'package:likeminds_feed_ss_fl/src/blocs/routing_bloc/routing_bloc.dart';
export 'package:likeminds_feed_ss_fl/src/blocs/profile_bloc/profile_bloc.dart';
export 'simple_bloc_observer.dart';
export 'listener/lm_bloc_listener.dart';

class LMFeedBloc {
  late final LMPostBloc lmPostBloc;
  late final LMAnalyticsBloc lmAnalyticsBloc;
  late final LMRoutingBloc lmRoutingBloc;
  late final LMProfileBloc lmProfileBloc;

  static LMFeedBloc? _instance;

  static LMFeedBloc get() => _instance ??= LMFeedBloc._();

  LMFeedBloc._();

  void initialize() {
    lmPostBloc = LMPostBloc();
    lmAnalyticsBloc = LMAnalyticsBloc();
    lmRoutingBloc = LMRoutingBloc();
    lmProfileBloc = LMProfileBloc();
  }

  Future<InitiateUserResponse> initiateUser(InitiateUserRequest request) async {
    InitiateUserResponse response =
        await locator<LMFeedClient>().initiateUser(request);
    if (response.success) {
      UserLocalPreference.instance.storeUserData(response.initiateUser!.user);
    }
    return response;
  }

  Future<MemberStateResponse> getMemberState() async {
    MemberStateResponse response =
        await locator<LMFeedClient>().getMemberState();
    if (response.success) {
      UserLocalPreference.instance
          .storeMemberRightsFromMemberStateResponse(response);
    }
    return response;
  }
}
