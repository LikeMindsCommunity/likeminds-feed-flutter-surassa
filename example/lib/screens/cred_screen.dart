import 'dart:async';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/app.dart';
import 'package:likeminds_feed_ss_sample/bloc_observer/analytics_bloc_listener.dart';
import 'package:likeminds_feed_ss_sample/bloc_observer/profile_bloc_listener.dart';
import 'package:likeminds_feed_ss_sample/bloc_observer/routing_bloc_listener.dart';
import 'package:likeminds_feed_ss_sample/main.dart';
import 'package:likeminds_feed_ss_sample/network_handling.dart';
import 'package:likeminds_feed_ss_sample/screens/activity_widget_screen.dart';
import 'package:likeminds_feed_ss_sample/screens/root_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:uni_links/uni_links.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      toastTheme: ToastThemeData(
        background: Colors.black,
        textColor: Colors.white,
        alignment: Alignment.bottomCenter,
      ),
      child: LMFeedTheme(
        theme: suraasaTheme,
        child: MaterialApp(
          title: 'Integration App for UI + SDK package',
          debugShowCheckedModeBanner: debug ? true : false,
          navigatorKey: rootNavigatorKey,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          theme: ThemeData(
            useMaterial3: false,
            primaryColor: Colors.deepPurple,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              outlineBorder: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
              activeIndicatorBorder: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
          home: const LMFeedBlocListener(
            analyticsListener: analyticsBlocListener,
            profileListener: profileBlocListener,
            routingListener: routingBlocListener,
            child: CredScreen(),
          ),
        ),
      ),
    );
  }
}

class CredScreen extends StatefulWidget {
  const CredScreen({super.key});

  @override
  State<CredScreen> createState() => _CredScreenState();
}

class _CredScreenState extends State<CredScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  StreamSubscription? _streamSubscription;
  String? userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initUniLinks(context);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _userIdController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future initUniLinks(BuildContext context) async {
    // Get the initial deep link if the app was launched with one
    final initialLink = await getInitialLink();

    // Handle the deep link
    if (initialLink != null) {
      initialURILinkHandled = true;
      // You can extract any parameters from the initialLink object here
      // and use them to navigate to a specific screen in your app
      debugPrint('Received initial deep link: $initialLink');

      // TODO: add api key to the DeepLinkRequest
      // TODO: add user id and user name of logged in user
      final uriLink = Uri.parse(initialLink);
      if (uriLink.isAbsolute) {
        final deepLinkRequestBuilder = LMFeedDeepLinkRequestBuilder()
          ..userId(userId ?? "Test-User-Id")
          ..userName("Test User");
        if (uriLink.path == '/community/post') {
          List secondPathSegment = initialLink.split('post_id=');
          if (secondPathSegment.length > 1 && secondPathSegment[1] != null) {
            String postId = secondPathSegment[1];

            // Call initiate user if not called already
            // It is recommened to call initiate user with your login flow
            // so that navigation works seemlessly
            InitiateUserResponse response = await LMFeedCore.instance
                .initiateUser((InitiateUserRequestBuilder()
                      ..userId(userId ?? "Test-User-Id")
                      ..userName("Test User"))
                    .build());

            if (response.success) {
              // Replace the below code
              // if you wanna navigate to your screen
              // Either navigatorKey or context must be provided
              // for the navigation to work
              // if both are null an exception will be thrown
              navigateToLMPostDetailsScreen(
                postId,
                navigatorKey: rootNavigatorKey,
              );
            }
          }
        } else if (uriLink.path == '/community/post/create') {
          rootNavigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LMFeedComposeScreen(),
            ),
          );
        }
      }
    }

    // Subscribe to link changes
    LMFeedCore.deepLinkStream = linkStream.listen((String? link) async {
      if (link != null) {
        initialURILinkHandled = true;
        // Handle the deep link
        // You can extract any parameters from the uri object here
        // and use them to navigate to a specific screen in your app
        debugPrint('Received deep link: $link');
        // TODO: add api key to the DeepLinkRequest
        // TODO: add user id and user name of logged in user

        final uriLink = Uri.parse(link);
        if (uriLink.isAbsolute) {
          if (uriLink.path == '/community/post') {
            List secondPathSegment = link.split('post_id=');
            if (secondPathSegment.length > 1 && secondPathSegment[1] != null) {
              String postId = secondPathSegment[1];

              InitiateUserResponse response = await LMFeedCore.instance
                  .initiateUser((InitiateUserRequestBuilder()
                        ..userId(userId ?? "Test-User-Id")
                        ..userName("Test User"))
                      .build());

              if (response.success) {
                // Replace the below code
                // if you wanna navigate to your screen
                // Either navigatorKey or context must be provided
                // for the navigation to work
                // if both are null an exception will be thrown
                navigateToLMPostDetailsScreen(
                  postId,
                  navigatorKey: rootNavigatorKey,
                );
              }
            }
          } else if (uriLink.path == '/community/post/create') {
            rootNavigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => const LMFeedComposeScreen(),
              ),
            );
          }
        }
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      toast('An error occurred');
    });
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);

    return Scaffold(
      backgroundColor: feedTheme.primaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [
            const SizedBox(height: 72),
            const Text(
              "LikeMinds Feed\nSample App",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 64),
            const Text(
              "Enter your credentials",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              controller: _usernameController,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                focusColor: Colors.white,
                labelText: 'Username',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              cursorColor: Colors.white,
              controller: _userIdController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                fillColor: Colors.white,
                focusColor: Colors.white,
                labelText: 'User ID',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: () async {
                String userId = _userIdController.text;
                String userName = _usernameController.text;

                if (userId.isEmpty && userName.isEmpty) {
                  return;
                }

                MaterialPageRoute route = MaterialPageRoute(
                  // INIT - Get the LMFeed instance and pass the credentials (if any)
                  builder: (context) => TabApp(
                    activityWidget: LMFeedActivityWidgetScreen(
                      uuid: userId,
                      postWidgetBuilder: (context, postWidget, postViewData) =>
                          suraasaPostWidgetBuilder(
                        context,
                        postWidget,
                        postViewData,
                        isFeed: true,
                      ),
                      commentWidgetBuilder: suraasaCommentWidgetBuilder,
                      appBarBuilder: suraasaPostDetailScreenAppBarBuilder,
                    ),
                    feedWidget: LMFeedSuraasa(
                      userId: userId,
                      userName: userName,
                    ),
                  ),
                );
                Navigator.of(context).push(route);
              },
              child: Container(
                width: 200,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text("Submit")),
              ),
            ),
            const SizedBox(height: 72),
            const Text(
              "If no credentials are provided, the app will run with the default credentials of Bot user in your community",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
