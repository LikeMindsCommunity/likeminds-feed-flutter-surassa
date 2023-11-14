part of '../analytics_bloc.dart';

fireAnalyticsEventHandler(
    FireAnalyticEvent event, Emitter<LMAnalyticsState> emit) async {
  emit(AnalyticsEventFired(
    eventName: event.eventName,
    eventProperties: event.eventProperties,
  ));
}
