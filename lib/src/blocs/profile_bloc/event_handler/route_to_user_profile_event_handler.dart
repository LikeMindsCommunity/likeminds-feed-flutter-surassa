part of '../profile_bloc.dart';

handleRouteToUserProfileEvent(
    RouteToUserProfile event, Emitter<LMProfileState> emit) {
  debugPrint("LM User ID caught in callback : ${event.userUniqueId}");
  emit(RouteToUserProfileState(userUniqueId: event.userUniqueId));
}
