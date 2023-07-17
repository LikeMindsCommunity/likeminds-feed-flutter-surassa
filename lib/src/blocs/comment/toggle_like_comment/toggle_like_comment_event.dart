part of 'toggle_like_comment_bloc.dart';

abstract class ToggleLikeCommentEvent extends Equatable {
  const ToggleLikeCommentEvent();

  @override
  List<Object> get props => [];
}

class ToggleLikeComment extends ToggleLikeCommentEvent {
  final ToggleLikeCommentRequest toggleLikeCommentRequest;
  const ToggleLikeComment({required this.toggleLikeCommentRequest});

  @override
  List<Object> get props => [toggleLikeCommentRequest];
}
