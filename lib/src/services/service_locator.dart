import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/services/bloc_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/navigation_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/icons.dart';

final GetIt locator = GetIt.I;

void _setupLocator(LMSDKCallback? callback, String apiKey,
    GlobalKey<NavigatorState> navigatorKey) {
  locator.allowReassignment = true;
  loadSvgIntoCache();
  if (!locator.isRegistered<LikeMindsService>()) {
    locator.registerSingleton(LikeMindsService(callback, apiKey));
  }
  if (!locator.isRegistered<NavigationService>()) {
    locator.registerSingleton(NavigationService(
      navigatorKey: navigatorKey,
    ));
  }
  if (!locator.isRegistered<BlocService>()) {
    locator.registerSingleton(BlocService());
  }
}

void setupLMFeed(LMSDKCallback? callback, String apiKey,
    GlobalKey<NavigatorState> navigatorKey) {
  _setupLocator(callback, apiKey, navigatorKey);
}
