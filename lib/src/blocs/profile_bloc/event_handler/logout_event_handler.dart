part of '../profile_bloc.dart';

handleLogoutEvent(Logout event, Emitter<LMProfileState> emit) =>
    emit(LogoutState());
