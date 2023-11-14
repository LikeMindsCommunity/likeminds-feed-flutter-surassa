// Events
import 'package:likeminds_feed_ss_fl/src/blocs/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/post_bloc/post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/profile_bloc/profile_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/routing_bloc/routing_bloc.dart';

export 'package:likeminds_feed_ss_fl/src/blocs/analytics_bloc/analytics_bloc.dart';
export 'package:likeminds_feed_ss_fl/src/blocs/post_bloc/post_bloc.dart';
export 'package:likeminds_feed_ss_fl/src/blocs/routing_bloc/routing_bloc.dart';
export 'package:likeminds_feed_ss_fl/src/blocs/profile_bloc/profile_bloc.dart';

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
}
