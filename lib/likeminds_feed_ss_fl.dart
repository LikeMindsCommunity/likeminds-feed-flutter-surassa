library likeminds_feed_ss_fl;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/views/universal_feed_page.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/credentials/credentials.dart';
import 'package:likeminds_feed_ss_fl/src/utils/local_preference/user_local_preference.dart';

export 'src/services/service_locator.dart';
export 'src/utils/analytics/analytics.dart';
export 'src/utils/notifications/notification_handler.dart';
export 'src/utils/share/share_post.dart';

/// Flutter environment manager v0.0.1
const prodFlag = !bool.fromEnvironment('DEBUG');

class LMFeed extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String apiKey;
  final LMSDKCallback callback;

  static LMFeed? _instance;

  /// INIT - Get the LMFeed instance and pass the credentials (if any)
  /// to the instance. This will be used to initialize the app.
  /// If no credentials are provided, the app will run with the default
  /// credentials of Bot user in your community in `credentials.dart`
  static LMFeed instance({
    String? userId,
    String? userName,
    required LMSDKCallback callback,
    required String apiKey,
  }) {
    setupLMFeed(callback, apiKey);
    return _instance ??= LMFeed._(
      userId: userId,
      userName: userName,
      callback: callback,
      apiKey: apiKey,
    );
  }

  const LMFeed._({
    Key? key,
    this.userId,
    this.userName,
    required this.callback,
    required this.apiKey,
  }) : super(key: key);

  @override
  _LMFeedState createState() => _LMFeedState();
}

class _LMFeedState extends State<LMFeed> {
  User? user;
  late final String userId;
  late final String userName;
  late final bool isProd;

  @override
  void initState() {
    super.initState();
    isProd = prodFlag;
    userId = widget.userId!.isEmpty
        ? isProd
            ? CredsProd.botId
            : CredsDev.botId
        : widget.userId!;
    userName = widget.userName!.isEmpty ? "Test username" : widget.userName!;
    // firebase();
  }

  // void firebase() {
  //   try {
  //     final firebase = Firebase.app();
  //     debugPrint("Firebase - ${firebase.options.appId}");
  //   } on FirebaseException catch (e) {
  //     debugPrint("Make sure you have initialized firebase, ${e.toString()}");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InitiateUserResponse>(
      future: locator<LikeMindsService>().initiateUser(
        (InitiateUserRequestBuilder()
              ..userId(userId)
              ..userName(userName))
            .build(),
      ),
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          InitiateUserResponse response = snapshot.data;
          if (response.success) {
            user = response.initiateUser?.user;
            UserLocalPreference.instance.storeUserData(user!);
            // LMNotificationHandler.instance.registerDevice(user!.id);
            return BlocProvider(
              create: (context) => NewPostBloc(),
              child: MaterialApp(
                debugShowCheckedModeBanner: !isProd,
                theme: ThemeData.from(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: kPrimaryColor,
                    primary: const Color.fromARGB(255, 70, 102, 246),
                    secondary: const Color.fromARGB(255, 59, 130, 246),
                  ),
                ),
                title: 'LM Feed',
                // navigatorKey: locator<NavigationService>().navigatorKey,
                // onGenerateRoute: (settings) {
                //   if (settings.name == NotificationScreen.route) {
                //     return MaterialPageRoute(
                //       builder: (context) => const NotificationScreen(),
                //     );
                //   }
                //   if (settings.name == AllCommentsScreen.route) {
                //     final args =
                //         settings.arguments as AllCommentsScreenArguments;
                //     return MaterialPageRoute(
                //       builder: (context) {
                //         return AllCommentsScreen(
                //           postId: args.postId,
                //           feedRoomId: args.feedRoomId,
                //           fromComment: args.fromComment,
                //         );
                //       },
                //     );
                //   }
                //   if (settings.name == LikesScreen.route) {
                //     final args = settings.arguments as LikesScreenArguments;
                //     return MaterialPageRoute(
                //       builder: (context) {
                //         return LikesScreen(
                //           postId: args.postId,
                //           commentId: args.commentId,
                //           isCommentLikes: args.isCommentLikes,
                //         );
                //       },
                //     );
                //   }
                //   if (settings.name == MediaPreviewScreen.routeName) {
                //     final args = settings.arguments as MediaPreviewArguments;
                //     return MaterialPageRoute(
                //       builder: (context) {
                //         return MediaPreviewScreen(
                //           attachments: args.attachments,
                //           postId: args.postId,
                //           mediaFile: args.mediaFile,
                //           mediaUrl: args.mediaUrl,
                //         );
                //       },
                //     );
                //   }
                //   if (settings.name == ReportPostScreen.route) {
                //     return MaterialPageRoute(
                //       builder: (context) {
                //         return const ReportPostScreen();
                //       },
                //     );
                //   }
                //   if (settings.name == NewPostScreen.route) {
                //     final args = settings.arguments as NewPostScreenArguments;
                //     return MaterialPageRoute(
                //       builder: (context) {
                //         return NewPostScreen(
                //           feedRoomId: args.feedroomId,
                //           feedRoomTitle: args.feedRoomTitle,
                //           isCm: args.isCm,
                //           populatePostMedia: args.populatePostMedia,
                //           populatePostText: args.populatePostText,
                //         );
                //       },
                //     );
                //   }

                //   if (settings.name == EditPostScreen.route) {
                //     final args = settings.arguments as EditPostScreenArguments;
                //     return MaterialPageRoute(
                //       builder: (context) {
                //         return EditPostScreen(
                //           postId: args.postId,
                //           feedRoomId: args.feedRoomId,
                //         );
                //       },
                //     );
                //   }

                //   if (settings.name == FeedRoomSelect.route) {
                //     final args = settings.arguments as FeedRoomSelectArguments;
                //     return MaterialPageRoute(
                //       builder: (context) {
                //         return FeedRoomSelect(
                //           user: args.user,
                //           feedRoomIds: args.feedRoomIds,
                //         );
                //       },
                //     );
                //   }
                //   return null;
                // },
                home: FutureBuilder(
                  future: locator<LikeMindsService>().getMemberState(),
                  initialData: null,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      final MemberStateResponse response = snapshot.data;
                      UserLocalPreference.instance.storeMemberRights(response);

                      return const UniversalFeedScreen();
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
  }
}
