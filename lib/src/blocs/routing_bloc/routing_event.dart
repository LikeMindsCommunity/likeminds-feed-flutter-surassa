part of 'routing_bloc.dart';

abstract class LMRoutingEvent extends Equatable {
  const LMRoutingEvent();

  @override
  List<Object> get props => [];
}

class LMRoutingEventInit extends LMRoutingEvent {}

class HandleSharedPostEvent extends LMRoutingEvent {
  final String postId;

  const HandleSharedPostEvent({required this.postId});

  @override
  List<Object> get props => [postId];
}

class HandlePostNotificationEvent extends LMRoutingEvent {
  final String postId;

  const HandlePostNotificationEvent({required this.postId});

  @override
  List<Object> get props => [postId];
}