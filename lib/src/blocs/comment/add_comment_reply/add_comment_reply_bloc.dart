import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/bloc.dart';
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
          addCommentReplyEvent: event,
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
      EditCommentReplyResponse? response = await locator<LMFeedClient>()
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
      EditCommentResponse? response =
          await locator<LMFeedClient>().editComment(event.editCommentRequest);
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
          final response = await locator<LMFeedClient>().deleteComment(
            event.deleteCommentRequest,
          );

          if (response.success) {
            toast(
              'Comment Deleted',
              duration: Toast.LENGTH_LONG,
            );
            LMAnalytics.get().track(AnalyticsKeys.commentDeleted, {
              "post_id": event.deleteCommentRequest.postId,
              "comment_id": event.deleteCommentRequest.commentId,
            });
            locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
                  eventName: AnalyticsKeys.commentDeleted,
                  eventProperties: {
                    "post_id": event.deleteCommentRequest.postId,
                    "comment_id": event.deleteCommentRequest.commentId,
                  },
                ));
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
        } on Exception catch (err, stacktrace) {
          toast(
            'An error occcurred while deleting comment',
            duration: Toast.LENGTH_LONG,
          );
          LMFeedLogger.instance.handleException(err, stacktrace);
          emit(CommentDeleteError());
        }
      },
    );
    on<DeleteCommentReply>(
      (event, emit) async {
        try {
          emit(ReplyDeletionLoading());
          final response = await locator<LMFeedClient>().deleteComment(
            event.deleteCommentReplyRequest,
          );

          if (response.success) {
            toast(
              'Comment Deleted',
              duration: Toast.LENGTH_LONG,
            );
            LMAnalytics.get().track(AnalyticsKeys.replyDeleted, {
              "post_id": event.deleteCommentReplyRequest.postId,
              "comment_reply_id": event.deleteCommentReplyRequest.commentId,
            });
            locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
                  eventName: AnalyticsKeys.replyDeleted,
                  eventProperties: {
                    "post_id": event.deleteCommentReplyRequest.postId,
                    "comment_reply_id":
                        event.deleteCommentReplyRequest.commentId,
                  },
                ));
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
      {required AddCommentReply addCommentReplyEvent,
      required Emitter<AddCommentReplyState> emit}) async {
    emit(AddCommentReplyLoading());
    AddCommentReplyResponse response = await locator<LMFeedClient>()
        .addCommentReply(addCommentReplyEvent.addCommentRequest);
    if (!response.success) {
      emit(const AddCommentReplyError(message: "An error occurred"));
    } else {
      LMAnalytics.get().track(
        AnalyticsKeys.replyPosted,
        {
          "post_id": addCommentReplyEvent.addCommentRequest.postId,
          "comment_id": addCommentReplyEvent.addCommentRequest.commentId,
          "comment_reply_id": response.reply?.id,
          "user_id": addCommentReplyEvent.userId
        },
      );
      locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
            eventName: AnalyticsKeys.replyPosted,
            eventProperties: {
              "post_id": addCommentReplyEvent.addCommentRequest.postId,
              "comment_id": addCommentReplyEvent.addCommentRequest.commentId,
              "comment_reply_id": response.reply?.id,
              "user_id": addCommentReplyEvent.userId
            },
          ));
      emit(AddCommentReplySuccess(addCommentResponse: response));
    }
  }
}
