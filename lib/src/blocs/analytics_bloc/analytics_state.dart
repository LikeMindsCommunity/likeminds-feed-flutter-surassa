part of 'analytics_bloc.dart';

abstract class LMAnalyticsState extends Equatable {
  const LMAnalyticsState();

  @override
  List<Object> get props => [];
}

class AnalyticsInitiated extends LMAnalyticsState {}

class AnalyticsEventFired extends LMAnalyticsState {
  final String eventName;
  final Map<String, dynamic> eventProperties;

  const AnalyticsEventFired({
    required this.eventName,
    required this.eventProperties,
  });

  @override
  List<Object> get props => [eventName, eventProperties];
}