// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'comment_replies_bloc.dart';

abstract class CommentRepliesState extends Equatable {
  const CommentRepliesState();
}

class CommentRepliesInitial extends CommentRepliesState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CommentRepliesLoaded extends CommentRepliesState {
  final GetCommentResponse commentDetails;
  final String commentId;
  final bool hasReachedMax;
  const CommentRepliesLoaded(
      {required this.commentDetails,
      required this.commentId,
      required this.hasReachedMax});

  @override
  List<Object?> get props => [commentDetails, hasReachedMax];
}

class CommentRepliesLoading extends CommentRepliesState {
  final String commentId;

  const CommentRepliesLoading({
    required this.commentId,
  });

  @override
  List<Object?> get props => [];
}

class PaginatedCommentRepliesLoading extends CommentRepliesState {
  final GetCommentResponse prevCommentDetails;
  final String commentId;

  const PaginatedCommentRepliesLoading({
    required this.prevCommentDetails,
    required this.commentId,
  });
  @override
  List<Object?> get props => [];
}

class CommentRepliesError extends CommentRepliesState {
  final String message;
  const CommentRepliesError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ClearedCommentReplies extends CommentRepliesState {
  final int time = DateTime.now().millisecondsSinceEpoch;
  @override
  List<Object?> get props => [time];
}
