part of 'analytics_bloc.dart';

abstract class LMAnalyticsEvent extends Equatable {
  const LMAnalyticsEvent();

  @override
  List<Object> get props => [];
}

class InitAnalyticEvent extends LMAnalyticsEvent {}

class FireAnalyticEvent extends LMAnalyticsEvent {
  final String eventName;
  final Map<String, dynamic> eventProperties;

  const FireAnalyticEvent({
    required this.eventName,
    required this.eventProperties,
  });

  @override
  List<Object> get props => [eventName, eventProperties];
}
