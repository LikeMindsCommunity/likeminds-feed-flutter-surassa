import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';

class LMBlocListener extends StatefulWidget {
  final Widget child;
  Function(BuildContext, LMAnalyticsState) analyticsListener;
  Function(BuildContext, LMRoutingState) routingListener;
  Function(BuildContext, LMProfileState) profileListener;

  LMBlocListener({
    super.key,
    required this.child,
    required this.analyticsListener,
    required this.profileListener,
    required this.routingListener,
  });

  @override
  State<LMBlocListener> createState() => _LMBlocListenerState();
}

class _LMBlocListenerState extends State<LMBlocListener> {
  @override
  void initState() {
    super.initState();
    Bloc.observer = SimpleBlocObserver();
  }

  @override
  Widget build(BuildContext context) {
    LMFeedBloc lmFeedBloc = locator<LMFeedBloc>();
    return MultiBlocListener(
      listeners: [
        BlocListener(
          listener: widget.profileListener,
          bloc: lmFeedBloc.lmProfileBloc,
        ),
        BlocListener(
          listener: widget.analyticsListener,
          bloc: locator<LMFeedBloc>().lmAnalyticsBloc,
        ),
        BlocListener(
          listener: widget.routingListener,
          bloc: lmFeedBloc.lmRoutingBloc,
        ),
      ],
      child: widget.child,
    );
  }
}
