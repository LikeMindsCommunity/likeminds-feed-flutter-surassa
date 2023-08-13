import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';

part 'universal_feed_event.dart';
part 'universal_feed_state.dart';

class UniversalFeedBloc extends Bloc<UniversalFeedEvent, UniversalFeedState> {
  // final FeedApi feedApi;
  UniversalFeedBloc() : super(UniversalFeedInitial()) {
    on<UniversalFeedEvent>((event, emit) async {
      if (event is GetUniversalFeed) {
        await _mapGetUniversalFeedToState(
            offset: event.offset, forLoadMore: event.forLoadMore, emit: emit);
      }
    });
  }

  bool hasReachedMax(UniversalFeedState state, bool forLoadMore) =>
      state is UniversalFeedLoaded && state.hasReachedMax && forLoadMore;

  FutureOr<void> _mapGetUniversalFeedToState(
      {required int offset,
      required bool forLoadMore,
      required Emitter<UniversalFeedState> emit}) async {
    // if (!hasReachedMax(state, forLoadMore)) {
    Map<String, User> users = {};
    if (state is UniversalFeedLoaded) {
      users = (state as UniversalFeedLoaded).feed.users;
      emit(PaginatedUniversalFeedLoading(
          prevFeed: (state as UniversalFeedLoaded).feed));
    } else {
      emit(UniversalFeedLoading());
    }
    GetFeedResponse? response = await locator<LikeMindsService>().getFeed(
      (GetFeedRequestBuilder()
            ..page(offset)
            ..pageSize(10))
          .build(),
    );

    if (response == null) {
      emit(const UniversalFeedError(
          message: "An error occurred, please check your network connection"));
    } else {
      response.users.addAll(users);
      emit(UniversalFeedLoaded(
          feed: response, hasReachedMax: response.posts.isEmpty));
    }
  }
}
