part of 'universal_feed_bloc.dart';

abstract class UniversalFeedEvent extends Equatable {
  const UniversalFeedEvent();
}

class GetUniversalFeed extends UniversalFeedEvent {
  final int offset;
  final bool forLoadMore;
  const GetUniversalFeed({required this.offset, required this.forLoadMore});
  @override
  List<Object?> get props => [offset, forLoadMore];
}
