part of 'add_comment_reply_bloc.dart';

abstract class AddCommentReplyEvent extends Equatable {
  const AddCommentReplyEvent();

  @override
  List<Object> get props => [];
}

// Add Comment events
class AddCommentReply extends AddCommentReplyEvent {
  final AddCommentReplyRequest addCommentRequest;
  const AddCommentReply({required this.addCommentRequest});

  @override
  List<Object> get props => [addCommentRequest];
}

class DeleteComment extends AddCommentReplyEvent {
  final DeleteCommentRequest deleteCommentRequest;
  const DeleteComment(this.deleteCommentRequest);
}

class DeleteCommentReply extends AddCommentReplyEvent {
  final DeleteCommentRequest deleteCommentReplyRequest;
  const DeleteCommentReply(this.deleteCommentReplyRequest);
}

class EditComment extends AddCommentReplyEvent {
  final EditCommentRequest editCommentRequest;
  const EditComment({required this.editCommentRequest});

  @override
  List<Object> get props => [editCommentRequest];
}

class EditCommentCancel extends AddCommentReplyEvent {}

class ReplyCommentCancel extends AddCommentReplyEvent {}

class EditingComment extends AddCommentReplyEvent {
  final String commentId;
  final String text;

  const EditingComment({required this.commentId, required this.text});
}

class EditReply extends AddCommentReplyEvent {
  final EditCommentReplyRequest editCommentReplyRequest;

  const EditReply({required this.editCommentReplyRequest});

  @override
  List<Object> get props => [editCommentReplyRequest];
}

class EditReplyCancel extends AddCommentReplyEvent {}

class EditingReply extends AddCommentReplyEvent {
  final String commentId;
  final String text;
  final String replyId;

  const EditingReply(
      {required this.commentId, required this.text, required this.replyId});
}
