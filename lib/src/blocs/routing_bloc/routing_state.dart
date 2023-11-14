part of 'routing_bloc.dart';

abstract class LMRoutingState extends Equatable {
  const LMRoutingState();

  @override
  List<Object> get props => [];
}

class LMRoutingStateInit extends LMRoutingState {}

class OpenSharedPost extends LMRoutingState {
  final String postId;

  const OpenSharedPost({required this.postId});

  @override
  List<Object> get props => [postId];
}

class OpenPostNotification extends LMRoutingState {
  final String postId;

  const OpenPostNotification({required this.postId});

  @override
  List<Object> get props => [postId];
}

class ErrorSharedPost extends LMRoutingState {
  final String message;
  final String postId;

  const ErrorSharedPost({required this.message, required this.postId});

  @override
  List<Object> get props => [message];
}

class ErrorPostNotification extends LMRoutingState {
  final String message;
  final String postId;

  const ErrorPostNotification({required this.message, required this.postId});

  @override
  List<Object> get props => [message];
}
