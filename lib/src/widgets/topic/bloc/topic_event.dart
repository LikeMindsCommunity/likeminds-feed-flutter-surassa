part of 'topic_bloc.dart';

abstract class TopicEvent extends Equatable {}

class InitTopicEvent extends TopicEvent {
  @override
  List<Object> get props => [];
}

class GetTopic extends TopicEvent {
  final GetTopicsRequest getTopicFeedRequest;

  GetTopic({required this.getTopicFeedRequest});

  @override
  List<Object> get props => [getTopicFeedRequest.toJson()];
}

class RefreshTopicEvent extends TopicEvent {
  @override
  List<Object> get props => [];
}
