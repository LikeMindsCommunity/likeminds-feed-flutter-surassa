part of 'add_comment_bloc.dart';

abstract class AddCommentEvent extends Equatable {
  const AddCommentEvent();

  @override
  List<Object> get props => [];
}

// Add Comment events
class AddComment extends AddCommentEvent {
  final AddCommentRequest addCommentRequest;
  const AddComment({required this.addCommentRequest});

  @override
  List<Object> get props => [addCommentRequest];
}
