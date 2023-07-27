part of 'toggle_like_comment_bloc.dart';

abstract class ToggleLikeCommentState extends Equatable {
  const ToggleLikeCommentState();

  @override
  List<Object> get props => [];
}

class ToggleLikeCommentInitial extends ToggleLikeCommentState {}

class ToggleLikeCommentLoading extends ToggleLikeCommentState {}

class ToggleLikeCommentSuccess extends ToggleLikeCommentState {
  final ToggleLikeCommentResponse toggleLikeCommentResponse;
  const ToggleLikeCommentSuccess({required this.toggleLikeCommentResponse});

  @override
  List<Object> get props => [toggleLikeCommentResponse];
}

class ToggleLikeCommentError extends ToggleLikeCommentState {
  final String message;
  const ToggleLikeCommentError({required this.message});

  @override
  List<Object> get props => [message];
}
