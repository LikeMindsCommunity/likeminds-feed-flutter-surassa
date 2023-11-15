part of 'profile_bloc.dart';

abstract class LMProfileEvent extends Equatable {
  const LMProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileEventInit extends LMProfileEvent {

}

class RouteToUserProfile extends LMProfileEvent {
  final String userUniqueId;

  const RouteToUserProfile({required this.userUniqueId});
}

class RouteToCompanyProfile extends LMProfileEvent {
  final String companyId;

  const RouteToCompanyProfile({required this.companyId});
}

class LoginRequired extends LMProfileEvent {}

class Logout extends LMProfileEvent {}