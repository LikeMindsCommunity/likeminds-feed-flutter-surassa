import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_sample/bloc_observer.dart/analytics_bloc_listener.dart';
import 'package:likeminds_feed_ss_sample/bloc_observer.dart/profile_bloc_listener.dart';
import 'package:likeminds_feed_ss_sample/bloc_observer.dart/routing_bloc_listener.dart';

class LMBlocObserver extends StatelessWidget {
  final Widget child;
  const LMBlocObserver({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    LMFeedBloc lmFeedBloc = locator<LMFeedBloc>();
    return MultiBlocListener(
      listeners: [
        BlocListener(
          listener: profileBlocListener,
          bloc: lmFeedBloc.lmProfileBloc,
        ),
        BlocListener(
          listener: analyticsBlocListener,
          bloc: lmFeedBloc.lmAnalyticsBloc,
        ),
        BlocListener(
          listener: routingBlocListener,
          bloc: lmFeedBloc.lmRoutingBloc,
        ),
      ],
      child: child,
    );
  }
}
