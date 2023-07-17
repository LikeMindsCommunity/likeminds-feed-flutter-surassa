import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';

part 'all_comments_event.dart';
part 'all_comments_state.dart';

class AllCommentsBloc extends Bloc<AllCommentsEvent, AllCommentsState> {
  AllCommentsBloc() : super(AllCommentsInitial()) {
    on<AllCommentsEvent>((event, emit) async {
      if (event is GetAllComments) {
        await _mapGetAllCommentsToState(
          postDetailRequest: event.postDetailRequest,
          forLoadMore: event.forLoadMore,
          emit: emit,
        );
      }
    });
  }

  FutureOr<void> _mapGetAllCommentsToState(
      {required PostDetailRequest postDetailRequest,
      required bool forLoadMore,
      required Emitter<AllCommentsState> emit}) async {
    // if (!hasReachedMax(state, forLoadMore)) {
    Map<String, User>? users = {};
    if (state is AllCommentsLoaded) {
      users = (state as AllCommentsLoaded).postDetails.users;
      emit(PaginatedAllCommentsLoading(
          prevPostDetails: (state as AllCommentsLoaded).postDetails));
    } else {
      emit(AllCommentsLoading());
    }

    PostDetailResponse response =
        await locator<LikeMindsService>().getPostDetails(postDetailRequest);
    if (!response.success) {
      emit(const AllCommentsError(message: "No data found"));
    } else {
      response.users!.addAll(users!);
      emit(AllCommentsLoaded(
          postDetails: response,
          hasReachedMax: response.postReplies!.replies.isEmpty));
    }
  }
}
