import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';
import 'package:likeminds_feed_ss_fl/src/utils/analytics/analytics.dart';
import 'package:overlay_support/overlay_support.dart';

part 'add_comment_reply_event.dart';

part 'add_comment_reply_state.dart';

class AddCommentReplyBloc
    extends Bloc<AddCommentReplyEvent, AddCommentReplyState> {
  AddCommentReplyBloc() : super(AddCommentReplyInitial()) {
    on<ReplyCommentCancel>((event, emit) => emit(ReplyCommentCanceled()));
    on<AddCommentReply>(
      (event, emit) async {
        await _mapAddCommentReplyToState(
          addCommentReplyRequest: event.addCommentRequest,
          emit: emit,
        );
      },
    );
    on<EditReplyCancel>(
      (event, emit) {
        emit(EditReplyCanceled());
      },
    );
    on<EditingReply>((event, emit) {
      emit(
        ReplyEditingStarted(
          commentId: event.commentId,
          text: event.text,
          replyId: event.replyId,
        ),
      );
    });
    on<EditReply>((event, emit) async {
      emit(EditReplyLoading());
      EditCommentReplyResponse? response = await locator<LikeMindsService>()
          .editCommentReply(event.editCommentReplyRequest);
      if (!response.success) {
        emit(const EditReplyError(message: "An error occurred"));
      } else {
        emit(EditReplySuccess(editCommentReplyResponse: response));
      }
    });
    on<EditCommentCancel>(
      (event, emit) {
        emit(EditCommentCanceled());
      },
    );
    on<EditingComment>((event, emit) {
      emit(
        CommentEditingStarted(
          commentId: event.commentId,
          text: event.text,
        ),
      );
    });
    on<EditComment>((event, emit) async {
      emit(EditCommentLoading());
      EditCommentResponse? response = await locator<LikeMindsService>()
          .editComment(event.editCommentRequest);
      if (!response.success) {
        emit(const EditCommentError(message: "An error occurred"));
      } else {
        emit(EditCommentSuccess(editCommentResponse: response));
      }
    });
    on<DeleteComment>(
      (event, emit) async {
        try {
          emit(CommentDeletionLoading());
          final response = await locator<LikeMindsService>().deleteComment(
            event.deleteCommentRequest,
          );

          if (response.success) {
            toast(
              'Comment Deleted',
              duration: Toast.LENGTH_LONG,
            );
            emit(
              CommentDeleted(
                commentId: event.deleteCommentRequest.commentId,
              ),
            );
          } else {
            toast(
              response.errorMessage ?? '',
              duration: Toast.LENGTH_LONG,
            );
            emit(CommentDeleteError());
          }
        } catch (err) {
          toast(
            'An error occcurred while deleting comment',
            duration: Toast.LENGTH_LONG,
          );
          emit(CommentDeleteError());
        }
      },
    );
    on<DeleteCommentReply>(
      (event, emit) async {
        try {
          emit(ReplyDeletionLoading());
          final response = await locator<LikeMindsService>().deleteComment(
            event.deleteCommentReplyRequest,
          );

          if (response.success) {
            toast(
              'Comment Deleted',
              duration: Toast.LENGTH_LONG,
            );
            emit(
              CommentReplyDeleted(
                replyId: event.deleteCommentReplyRequest.commentId,
              ),
            );
          } else {
            toast(
              response.errorMessage ?? '',
              duration: Toast.LENGTH_LONG,
            );
            emit(CommentDeleteError());
          }
        } catch (err) {
          toast(
            'An error occcurred while deleting reply',
            duration: Toast.LENGTH_LONG,
          );
          emit(CommentDeleteError());
        }
      },
    );
  }

  FutureOr<void> _mapAddCommentReplyToState(
      {required AddCommentReplyRequest addCommentReplyRequest,
      required Emitter<AddCommentReplyState> emit}) async {
    emit(AddCommentReplyLoading());
    AddCommentReplyResponse response = await locator<LikeMindsService>()
        .addCommentReply(addCommentReplyRequest);
    if (!response.success) {
      emit(const AddCommentReplyError(message: "An error occurred"));
    } else {
      LMAnalytics.get().track(
        AnalyticsKeys.replyPosted,
        {
          "post_id": addCommentReplyRequest.postId,
          "comment_id": addCommentReplyRequest.commentId,
        },
      );
      emit(AddCommentReplySuccess(addCommentResponse: response));
    }
  }
}
