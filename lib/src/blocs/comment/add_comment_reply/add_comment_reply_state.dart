part of 'add_comment_reply_bloc.dart';

abstract class AddCommentReplyState extends Equatable {
  const AddCommentReplyState();

  @override
  List<Object> get props => [];
}

class AddCommentReplyInitial extends AddCommentReplyState {}

class AddCommentReplyLoading extends AddCommentReplyState {}

class AddCommentReplySuccess extends AddCommentReplyState {
  final AddCommentReplyResponse addCommentResponse;
  const AddCommentReplySuccess({required this.addCommentResponse});
}

class AddCommentReplyError extends AddCommentReplyState {
  final String message;
  const AddCommentReplyError({required this.message});
}

class CommentEditingStarted extends AddCommentReplyState {
  final String commentId;
  final String text;

  const CommentEditingStarted({required this.commentId, required this.text});
}

class EditCommentLoading extends AddCommentReplyState {}

class EditCommentCanceled extends AddCommentReplyState {}

class EditCommentSuccess extends AddCommentReplyState {
  final EditCommentResponse editCommentResponse;

  const EditCommentSuccess({required this.editCommentResponse});
}

class EditCommentError extends AddCommentReplyState {
  final String message;
  const EditCommentError({required this.message});
}

class ReplyEditingStarted extends AddCommentReplyState {
  final String commentId;
  final String text;
  final String replyId;

  const ReplyEditingStarted(
      {required this.commentId, required this.text, required this.replyId});
}

class EditReplyLoading extends AddCommentReplyState {}

class EditReplyCanceled extends AddCommentReplyState {}

class ReplyCommentCanceled extends AddCommentReplyState {}

class EditReplySuccess extends AddCommentReplyState {
  final EditCommentReplyResponse editCommentReplyResponse;

  const EditReplySuccess({required this.editCommentReplyResponse});
}

class EditReplyError extends AddCommentReplyState {
  final String message;
  const EditReplyError({required this.message});
}

class CommentDeletionLoading extends AddCommentReplyState {}

class CommentDeleted extends AddCommentReplyState {
  final String commentId;
  const CommentDeleted({
    required this.commentId,
  });
}

class CommentDeleteError extends AddCommentReplyState {}

class ReplyDeletionLoading extends AddCommentReplyState {}

class CommentReplyDeleted extends AddCommentReplyState {
  final String replyId;
  const CommentReplyDeleted({
    required this.replyId,
  });
}

class CommentReplyDeleteError extends AddCommentReplyState {}
