import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'routing_event.dart';

part 'routing_state.dart';

part 'handler/share_post_event_handler.dart';
part 'handler/post_notification_event_handler.dart';

class LMRoutingBloc extends Bloc<LMRoutingEvent, LMRoutingState> {
  LMRoutingBloc() : super(LMRoutingStateInit()) {
    on<HandleSharedPostEvent>(sharePostEventHandler);
    on<HandlePostNotificationEvent>(postNotificationEventHandler);
  }
}
