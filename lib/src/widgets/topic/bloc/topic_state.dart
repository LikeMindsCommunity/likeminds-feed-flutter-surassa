part of 'topic_bloc.dart';

abstract class TopicState {}

class TopicInitial extends TopicState {}

class TopicLoading extends TopicState {}

class TopicError extends TopicState {
  final String errorMessage;

  TopicError(this.errorMessage);
}

class TopicLoaded extends TopicState {
  final GetTopicsResponse getTopicFeedResponse;

  TopicLoaded(this.getTopicFeedResponse);
}
