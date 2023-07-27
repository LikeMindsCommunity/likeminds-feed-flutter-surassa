part of 'comment_replies_bloc.dart';

abstract class CommentRepliesEvent extends Equatable {
  const CommentRepliesEvent();
}

class GetCommentReplies extends CommentRepliesEvent {
  final GetCommentRequest commentDetailRequest;

  final bool forLoadMore;
  const GetCommentReplies(
      {required this.commentDetailRequest, required this.forLoadMore});

  @override
  List<Object?> get props => [commentDetailRequest, forLoadMore];
}

class ClearCommentReplies extends CommentRepliesEvent {
  final int time = DateTime.now().millisecondsSinceEpoch;
  @override
  List<Object?> get props => [time];
}
