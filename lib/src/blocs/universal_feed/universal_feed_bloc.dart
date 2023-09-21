import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

part 'universal_feed_event.dart';
part 'universal_feed_state.dart';

class UniversalFeedBloc extends Bloc<UniversalFeedEvent, UniversalFeedState> {
  // final FeedApi feedApi;
  UniversalFeedBloc() : super(UniversalFeedInitial()) {
    on<UniversalFeedEvent>((event, emit) async {
      if (event is GetUniversalFeed) {
        await _mapGetUniversalFeedToState(
            event: event, offset: event.offset, emit: emit);
      }
    });
  }

  bool hasReachedMax(UniversalFeedState state, bool forLoadMore) =>
      state is UniversalFeedLoaded && state.hasReachedMax && forLoadMore;

  FutureOr<void> _mapGetUniversalFeedToState(
      {required GetUniversalFeed event,
      required int offset,
      required Emitter<UniversalFeedState> emit}) async {
    // if (!hasReachedMax(state, forLoadMore)) {
    Map<String, User> users = {};
    Map<String, Topic> topics = {};
    if (state is UniversalFeedLoaded) {
      users = (state as UniversalFeedLoaded).feed.users;
      topics = (state as UniversalFeedLoaded).feed.topics;
      emit(PaginatedUniversalFeedLoading(
          prevFeed: (state as UniversalFeedLoaded).feed));
    } else {
      emit(UniversalFeedLoading());
    }
    List<Topic> selectedTopics = [];
    if (event.topics != null && event.topics!.isNotEmpty) {
      selectedTopics = event.topics!.map((e) => e.toTopic()).toList();
    }
    GetFeedResponse? response = await locator<LikeMindsService>().getFeed(
      (GetFeedRequestBuilder()
            ..page(offset)
            ..topics(selectedTopics)
            ..pageSize(10))
          .build(),
    );

    if (response == null) {
      emit(const UniversalFeedError(
          message: "An error occurred, please check your network connection"));
    } else {
      response.users.addAll(users);
      response.topics.addAll(topics);
      emit(UniversalFeedLoaded(
          topics: event.topics ?? [],
          feed: response,
          hasReachedMax: response.posts.isEmpty));
    }
  }
}
