import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMBlocListener extends StatefulWidget {
  final Widget child;
  Function(BuildContext, LMFeedAnalyticsState) analyticsListener;
  Function(BuildContext, LMFeedRoutingState) routingListener;
  Function(BuildContext, LMFeedProfileState) profileListener;

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
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener(
          listener: widget.profileListener,
          bloc: LMFeedProfileBloc.instance,
        ),
        BlocListener(
          listener: widget.analyticsListener,
          bloc: LMFeedAnalyticsBloc.instance,
        ),
        BlocListener(
          listener: widget.routingListener,
          bloc: LMFeedRoutingBloc.instance,
        ),
      ],
      child: widget.child,
    );
  }
}
