import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/post_bloc/post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/media_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/navigation_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/credentials/credentials.dart';
import 'package:likeminds_feed_ss_fl/src/utils/icons.dart';

final GetIt locator = GetIt.I;

void _setupLocator(LMSDKCallback? callback, String apiKey,
    GlobalKey<NavigatorState> navigatorKey) {
  locator.allowReassignment = true;
  loadSvgIntoCache();

  // TODO: Remove NavigationService
  if (!locator.isRegistered<NavigationService>()) {
    locator.registerSingleton(NavigationService(
      navigatorKey: navigatorKey,
    ));
  }

  MediaService _mediaService = MediaService(prodFlag);

  LMAnalytics.get().initialize();

  LMFeedClient lmFeedClient = (LMFeedClientBuilder()
        ..apiKey(apiKey)
        ..sdkCallback(callback))
      .build();

  if (!locator.isRegistered<LMFeedClient>()) {
    locator.registerSingleton(lmFeedClient);
  }

  if(!locator.isRegistered<MediaService>()){
    locator.registerSingleton(_mediaService);
  }

  if (!locator.isRegistered<LMPostBloc>()) {
    LMPostBloc lmPostBloc = LMPostBloc();
    locator.registerSingleton(lmPostBloc);
  }
}

void setupLMFeed(LMSDKCallback? callback, String apiKey,
    GlobalKey<NavigatorState> navigatorKey) {
  _setupLocator(callback, apiKey, navigatorKey);
}
