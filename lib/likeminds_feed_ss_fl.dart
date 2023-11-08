library likeminds_feed_ss_fl;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_no_internet_widget/flutter_no_internet_widget.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/services/navigation_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/network_handling.dart';
import 'package:likeminds_feed_ss_fl/src/utils/utils.dart';
import 'package:likeminds_feed_ss_fl/src/views/universal_feed_page.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/credentials/credentials.dart';

export 'src/services/service_locator.dart';
export 'src/utils/analytics/analytics.dart';
export 'src/utils/notifications/notification_handler.dart';
export 'src/utils/share/share_post.dart';
export 'src/utils/local_preference/user_local_preference.dart';

/// Flutter environment manager v0.0.1
const prodFlag = !bool.fromEnvironment('DEBUG');

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class LMFeed extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String apiKey;
  final String? imageUrl;
  final Function(BuildContext context)? openChatCallback;
  final LMSDKCallback? callback;

  static LMFeed? _instance;

  /// INIT - Get the LMFeed instance and pass the credentials (if any)
  /// to the instance. This will be used to initialize the app.
  /// If no credentials are provided, the app will run with the default
  /// credentials of Bot user in your community in `credentials.dart`
  static LMFeed instance({
    String? userId,
    String? userName,
    String? imageUrl,
    LMSDKCallback? callback,
    Function(BuildContext context)? openChatCallback,
    required String apiKey,
  }) {
    return LMFeed._(
      userId: userId,
      userName: userName,
      callback: callback,
      apiKey: apiKey,
      imageUrl: imageUrl,
      openChatCallback: openChatCallback,
    );
  }

  static void setupFeed({
    required String apiKey,
    LMSDKCallback? lmCallBack,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    setupLMFeed(
      lmCallBack,
      apiKey,
      navigatorKey,
    );
  }

  static void logout() {
    locator<LikeMindsService>().logout(LogoutRequestBuilder().build());
  }

  const LMFeed._(
      {Key? key,
      this.userId,
      this.userName,
      this.imageUrl,
      required this.callback,
      required this.apiKey,
      this.openChatCallback})
      : super(key: key);

  @override
  _LMFeedState createState() => _LMFeedState();
}

class _LMFeedState extends State<LMFeed> {
  User? user;
  late final String userId;
  String? imageUrl;
  late final String userName;
  late final bool isProd;
  late final NetworkConnectivity networkConnectivity;
  late final Future<InitiateUserResponse> initiateUser;
  ValueNotifier<bool> rebuildOnConnectivityChange = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    networkConnectivity = NetworkConnectivity.instance;
    networkConnectivity.initialise();

    isProd = prodFlag;
    userId = widget.userId!.isEmpty
        ? isProd
            ? CredsProd.botId
            : CredsDev.botId
        : widget.userId!;
    imageUrl = widget.imageUrl;
    userName = widget.userName!.isEmpty ? "Test username" : widget.userName!;
    if (imageUrl == null || imageUrl!.isEmpty) {
      initiateUser =  locator<LikeMindsService>().initiateUser(
          (InitiateUserRequestBuilder()
            ..userId(userId)
            ..userName(userName))
              .build());
    } else {
      initiateUser = locator<LikeMindsService>().initiateUser(
          (InitiateUserRequestBuilder()
            ..userId(userId)
            ..userName(userName)
            ..imageUrl(imageUrl!))
              .build());
    }
    firebase();
  }

  void firebase() {
    try {
      final firebase = Firebase.app();
      debugPrint("Firebase - ${firebase.options.appId}");
    } on FirebaseException catch (e) {
      debugPrint("Make sure you have initialized firebase, ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screeSize = MediaQuery.of(context).size;
    return InternetWidget(
      offline: FullScreenWidget(
        child: Container(
          width: screeSize.width,
          color: Colors.white,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.signal_wifi_off,
                size: 40,
                color: kPrimaryColor,
              ),
              kVerticalPaddingLarge,
              Text(
                "No internet\nCheck your connection and try again",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      connectivity: networkConnectivity.networkConnectivity,
      // ignore: avoid_print
      whenOffline: () {
        debugPrint('No Internet');
        rebuildOnConnectivityChange.value = !rebuildOnConnectivityChange.value;
      },
      // ignore: avoid_print
      whenOnline: () {
        debugPrint('Connected to internet');
        rebuildOnConnectivityChange.value = !rebuildOnConnectivityChange.value;
      },
      loadingWidget: const Center(child: CircularProgressIndicator()),
      online: ValueListenableBuilder(
        valueListenable: rebuildOnConnectivityChange,
        builder: (context, _, __) {
          return FutureBuilder<InitiateUserResponse>(
            future: initiateUser,
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                InitiateUserResponse response = snapshot.data;
                if (response.success) {
                  user = response.initiateUser?.user;

                  //Get community configurations
                  locator<LikeMindsService>().getCommunityConfigurations();

                  LMNotificationHandler.instance.registerDevice(user!.id);
                  return MaterialApp(
                    theme: suraasaTheme,
                    debugShowCheckedModeBanner: !isProd,
                    navigatorKey: locator<NavigationService>().navigatorKey,
                    title: 'LM Feed',
                    home: FutureBuilder(
                      future: locator<LikeMindsService>().getMemberState(),
                      initialData: null,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return UniversalFeedScreen(
                            openChatCallback: widget.openChatCallback,
                          );
                        }

                        return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          color: kBackgroundColor,
                          child: const Center(
                            child: LMLoader(
                              isPrimary: true,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {}
              } else if (snapshot.hasError) {
                debugPrint("Error - ${snapshot.error}");
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: kBackgroundColor,
                  child: const Center(
                    child: Text("An error has occured",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        )),
                  ),
                );
              }
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: kBackgroundColor,
              );
            },
          );
        },
      ),
    );
  }
}
