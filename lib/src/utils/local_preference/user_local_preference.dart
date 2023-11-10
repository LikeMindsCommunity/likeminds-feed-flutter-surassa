import 'dart:convert';

import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
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
    String? userDataString = _sharedPreferences!.getString(_userKey);

    Map<String, dynamic> userData = jsonDecode(userDataString!);
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
    String? getMemberStateString =
        _sharedPreferences!.getString('memberRights');

    if (getMemberStateString == null) {
      locator<LMFeedClient>().getMemberState();
      return MemberStateResponse(
          success: false, errorMessage: "An error occurred");
    }

    Map<String, dynamic> memberRights =
        jsonDecode(_sharedPreferences!.getString('memberRights')!);
    return MemberStateResponse.fromJson(memberRights);
  }

  bool fetchMemberRight(int id) {
    MemberStateResponse memberStateResponse = fetchMemberRights();
    if (memberStateResponse.success == false ||
        memberStateResponse.memberRights == null) {
      return true;
    }
    final memberRights = memberStateResponse.memberRights;

    final right = memberRights!.where((element) => element.state == id);
    if (right.isEmpty) {
      return true;
    } else {
      return right.first.isSelected;
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
    String? communityConfigurationString =
        _sharedPreferences!.getString('communityConfigurations');

    if (communityConfigurationString == null) {
      return CommunityConfigurations(value: {}, type: '', description: '');
    }

    Map<String, dynamic> communityConfigurations =
        jsonDecode(communityConfigurationString);

    final entity =
        CommunityConfigurationsEntity.fromJson(communityConfigurations);
    return CommunityConfigurations.fromEntity(entity);
  }

  Future<void> clearLocalPrefs() async {
    await _sharedPreferences!.clear();
  }
}
