import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/media_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/navigation_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/icons.dart';

final GetIt locator = GetIt.I;

Future<void> _setupLocator(LMSDKCallback? callback, String apiKey,
    GlobalKey<NavigatorState> navigatorKey) async {
  locator.allowReassignment = true;
  loadSvgIntoCache();

  if (!locator.isRegistered<NavigationService>()) {
    locator.registerSingleton(NavigationService(
      navigatorKey: navigatorKey,
    ));
  }

  UserLocalPreference.instance.initialize();

  MediaService mediaService = MediaService(prodFlag);

  LMAnalytics.get().initialize();

  LMFeedClient lmFeedClient = (LMFeedClientBuilder()
        ..apiKey(apiKey)
        ..sdkCallback(callback))
      .build();

  if (!locator.isRegistered<LMFeedClient>()) {
    locator.registerSingleton(lmFeedClient);
  }

  if (!locator.isRegistered<MediaService>()) {
    locator.registerSingleton(mediaService);
  }

  if (!locator.isRegistered<LMFeedBloc>()) {
    LMFeedBloc lmFeedBloc = LMFeedBloc.get();
    lmFeedBloc.initialize();
    locator.registerSingleton(lmFeedBloc);
  }
}

Future<void> setupLMFeed(LMSDKCallback? callback, String apiKey,
    GlobalKey<NavigatorState> navigatorKey) async {
 await _setupLocator(callback, apiKey, navigatorKey);
}
