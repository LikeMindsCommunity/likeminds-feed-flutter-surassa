import 'dart:convert';

import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalPreference {
  SharedPreferences? _sharedPreferences;

  static UserLocalPreference? _instance;
  static UserLocalPreference get instance =>
      _instance ??= UserLocalPreference._();

  UserLocalPreference._();

  final String _userKey = 'user';
  final String _memberStateKey = 'isCm';

  Future<void> initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> storeUserData(User user) async {
    UserEntity userEntity = user.toEntity();
    Map<String, dynamic> userData = userEntity.toJson();
    String userString = jsonEncode(userData);
    await _sharedPreferences!.setString(_userKey, userString);
  }

  User fetchUserData() {
    Map<String, dynamic> userData =
        jsonDecode(_sharedPreferences!.getString(_userKey)!);
    return User.fromEntity(UserEntity.fromJson(userData));
  }

  Future<void> storeMemberState(bool isCm) async {
    await _sharedPreferences!.setBool(_memberStateKey, isCm);
  }

  bool fetchMemberState() {
    return _sharedPreferences!.getBool(_memberStateKey)!;
  }

  Future<void> storeMemberRights(MemberStateResponse response) async {
    final entity = response.toEntity();
    Map<String, dynamic> memberRights = entity.toJson();
    String memberRightsString = jsonEncode(memberRights);
    await storeMemberState(response.state == 1);
    await _sharedPreferences!.setString('memberRights', memberRightsString);
  }

  MemberStateResponse fetchMemberRights() {
    Map<String, dynamic> memberRights =
        jsonDecode(_sharedPreferences!.getString('memberRights')!);
    return MemberStateResponse.fromJson(memberRights);
  }

  bool fetchMemberRight(int id) {
    MemberStateResponse memberStateResponse = fetchMemberRights();
    final memberRights = memberStateResponse.memberRights;
    if (memberRights == null) {
      return true;
    } else {
      final right = memberRights.where((element) => element.state == id);
      if (right.isEmpty) {
        return true;
      } else {
        return right.first.isSelected;
      }
    }
  }

  Future<void> setUserDataFromInitiateUserResponse(
      InitiateUserResponse response) async {
    if (response.success) {
      await UserLocalPreference.instance
          .storeUserData(response.initiateUser!.user);
    }
  }

  Future<void> storeMemberRightsFromMemberStateResponse(
      MemberStateResponse response) async {
    if (response.success) {
      await UserLocalPreference.instance.storeMemberRights(response);
    }
  }

  Future<void> storeCommunityConfigurations(
      CommunityConfigurations configurations) async {
    final configString = jsonEncode(configurations.toEntity().toJson());
    await _sharedPreferences!
        .setString('communityConfigurations', configString);
  }

  Future<CommunityConfigurations> getCommunityConfigurations() async {
    Map<String, dynamic> communityConfigurations =
        jsonDecode(_sharedPreferences!.getString('communityConfigurations')!);
    final entity =
        CommunityConfigurationsEntity.fromJson(communityConfigurations);
    return CommunityConfigurations.fromEntity(entity);
  }

  Future<void> clearLocalPrefs() async {
    await _sharedPreferences!.clear();
  }
}
