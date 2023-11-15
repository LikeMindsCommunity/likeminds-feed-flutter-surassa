part of 'profile_bloc.dart';

abstract class LMProfileState extends Equatable {
  const LMProfileState();

  @override
  List<Object> get props => [];
}

class LMProfileStateInit extends LMProfileState {}

class RouteToUserProfileState extends LMProfileState {
  final String userUniqueId;

  const RouteToUserProfileState({required this.userUniqueId});

  @override
  List<Object> get props => [userUniqueId];
}

class LoginRequiredState extends LMProfileState {}

class LogoutState extends LMProfileState {}

class RouteToCompanyProfileState extends LMProfileState {
  final String companyId;

  const RouteToCompanyProfileState({required this.companyId});

  @override
  List<Object> get props => [companyId];
}
