import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_bloc_fl/likeminds_feed_bloc_fl.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/services/bloc_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/navigation_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/credentials/credentials.dart';
import 'package:likeminds_feed_ss_fl/src/utils/icons.dart';

final GetIt locator = GetIt.I;

void _setupLocator(LMSDKCallback? callback, String apiKey,
    GlobalKey<NavigatorState> navigatorKey) {
  locator.allowReassignment = true;
  loadSvgIntoCache();

  // TODO: Remove LikeMindsService
  if (!locator.isRegistered<LikeMindsService>()) {
    locator.registerSingleton(LikeMindsService(callback, apiKey));
  }

  // TODO: Remove NavigationService
  if (!locator.isRegistered<NavigationService>()) {
    locator.registerSingleton(NavigationService(
      navigatorKey: navigatorKey,
    ));
  }

  // TODO: Remove BLoC Service
  if (!locator.isRegistered<BlocService>()) {
    locator.registerSingleton(BlocService());
  }

  LMFeedClient lmFeedClient = (LMFeedClientBuilder()
        ..apiKey(apiKey)
        ..sdkCallback(callback))
      .build();

  if (!locator.isRegistered<LMFeedClient>()) {
    locator.registerSingleton(lmFeedClient);
  }

  if (!locator.isRegistered<LMFeedBloc>()) {
    LMFeedBloc.get().initialize(
      lmFeedClient: lmFeedClient,
      mediaService: MediaService(
        bucketName: prodFlag ? CredsProd.bucketName : CredsDev.bucketName,
        poolId: prodFlag ? CredsProd.poolId : CredsDev.poolId,
      ),
    );
    locator.registerSingleton(LMFeedBloc.get());
  }
}

void setupLMFeed(LMSDKCallback? callback, String apiKey,
    GlobalKey<NavigatorState> navigatorKey) {
  _setupLocator(callback, apiKey, navigatorKey);
}
