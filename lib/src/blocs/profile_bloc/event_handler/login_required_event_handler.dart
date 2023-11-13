part of '../profile_bloc.dart';

handleLoginRequiredEvent(LoginRequired event, Emitter<LMProfileState> emit) =>
    emit(LoginRequiredState());
