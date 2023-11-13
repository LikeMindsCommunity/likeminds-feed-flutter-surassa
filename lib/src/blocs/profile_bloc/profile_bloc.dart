import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

part 'profile_event.dart';

part 'profile_state.dart';

part 'event_handler/login_required_event_handler.dart';

part 'event_handler/logout_event_handler.dart';

part 'event_handler/route_to_company_profile_event_handler.dart';

part 'event_handler/route_to_user_profile_event_handler.dart';



class LMRoutingBloc extends Bloc<LMProfileEvent, LMProfileState> {
  LMRoutingBloc() : super(LMProfileStateInit()) {
    on<LoginRequired>(handleLoginRequiredEvent);
    on<Logout>(handleLogoutEvent);
    on<RouteToCompanyProfile>(handleRouteToCompanyProfileEvent);
    on<RouteToUserProfile>(handleRouteToUserProfileEvent);
  }
}
