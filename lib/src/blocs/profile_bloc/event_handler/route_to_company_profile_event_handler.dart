part of '../profile_bloc.dart';

handleRouteToCompanyProfileEvent(
    RouteToCompanyProfile event, Emitter<LMProfileState> emit) {
  debugPrint("Company ID caught in callback : ${event.companyId}");
  emit(RouteToCompanyProfileState(companyId: event.companyId));
}
