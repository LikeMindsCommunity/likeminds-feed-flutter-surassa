import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';
import 'package:likeminds_feed_ss_fl/src/utils/analytics/analytics.dart';

part 'add_comment_event.dart';
part 'add_comment_state.dart';

class AddCommentBloc extends Bloc<AddCommentEvent, AddCommentState> {
  AddCommentBloc() : super(AddCommentInitial()) {
    on<AddComment>(
      (event, emit) async {
        await _mapAddCommentToState(
          addCommentRequest: event.addCommentRequest,
          emit: emit,
        );
      },
    );
  }

  FutureOr<void> _mapAddCommentToState(
      {required AddCommentRequest addCommentRequest,
      required Emitter<AddCommentState> emit}) async {
    emit(AddCommentLoading());
    AddCommentResponse? response =
        await locator<LikeMindsService>().addComment(addCommentRequest);
    if (!response.success) {
      emit(const AddCommentError(message: "An error occurred"));
    } else {
      LMAnalytics.get().track(
        AnalyticsKeys.commentPosted,
        {
          "post_id": addCommentRequest.postId,
          "comment_id": response.reply?.id,
        },
      );
      emit(AddCommentSuccess(addCommentResponse: response));
    }
  }
}
