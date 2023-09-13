part of 'universal_feed_bloc.dart';

abstract class UniversalFeedEvent extends Equatable {
  const UniversalFeedEvent();
}

class GetUniversalFeed extends UniversalFeedEvent {
  final int offset;
  final List<TopicUI>? topics;
  const GetUniversalFeed({required this.offset, this.topics});
  @override
  List<Object?> get props => [offset, topics];
}
