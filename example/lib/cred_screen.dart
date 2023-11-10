import 'dart:async';

import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_sample/likeminds_callback.dart';
import 'package:likeminds_feed_ss_sample/main.dart';
import 'package:likeminds_feed_ss_sample/network_handling.dart';
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
      child: MaterialApp(
        title: 'Integration App for UI + SDK package',
        debugShowCheckedModeBanner: false,
        //navigatorKey: rootNavigatorKey,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.deepPurple,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            outlineBorder: const BorderSide(
              color: Colors.deepPurple,
              width: 2,
            ),
            activeIndicatorBorder: const BorderSide(
              color: Colors.deepPurple,
              width: 2,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
          ),
        ),
        home: const CredScreen(),
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
  LMFeed? lmFeed;
  String? userId;

  @override
  void initState() {
    super.initState();
    NetworkConnectivity networkConnectivity = NetworkConnectivity.instance;
    networkConnectivity.initialise();
    // userId = UserLocalPreference.instance.fetchUserId();
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
    if (!initialURILinkHandled) {
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
        SharePost().parseDeepLink(
            (DeepLinkRequestBuilder()
                  ..apiKey(SharePost.apiKey)
                  ..callback(LikeMindsCallback())
                  ..isGuest(false)
                  ..link(initialLink)
                  ..userName("Test User")
                  ..userUniqueId(userId ?? "Test-User-Id"))
                .build(), rootNavigatorKey
            );
      }

      // Subscribe to link changes
      _streamSubscription = linkStream.listen((String? link) async {
        initialURILinkHandled = true;
        if (link != null) {
          initialURILinkHandled = true;
          // Handle the deep link
          // You can extract any parameters from the uri object here
          // and use them to navigate to a specific screen in your app
          debugPrint('Received deep link: $link');
          // TODO: add api key to the DeepLinkRequest
          // TODO: add user id and user name of logged in user
          SharePost().parseDeepLink(
              (DeepLinkRequestBuilder()
                    ..apiKey(SharePost.apiKey)
                    ..isGuest(false)
                    ..callback(LikeMindsCallback())
                    ..link(link)
                    ..userName("Test User")
                    ..userUniqueId(userId ?? "Test-User-Id"))
                  .build(),
              rootNavigatorKey);
        }
      }, onError: (err) {
        // Handle exception by warning the user their action did not succeed
        toast('An error occurred');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return lmFeed;
    userId = null; // UserLocalPreference.instance.fetchUserId();
    // If the local prefs have user id stored
    // Login using that user Id
    // otherwise show the cred screen for login
    if (userId != null && userId!.isNotEmpty) {
      return lmFeed = LMFeed.instance(
        userId: userId,
        userName: 'Test User',
        callback: LikeMindsCallback(),
        apiKey: "",
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 6, 92, 193),
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
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Username',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                cursorColor: Colors.white,
                controller: _userIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'User ID',
                    labelStyle: const TextStyle(
                      color: Colors.white,
                    )),
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () {
                  lmFeed = LMFeed.instance(
                    userId: _userIdController.text,
                    userName: _usernameController.text,
                    callback: LikeMindsCallback(),
                    apiKey: "",
                  );

                  // if (_userIdController.text.isNotEmpty) {
                  //   UserLocalPreference.instance
                  //       .storeUserId(_userIdController.text);
                  // } else {
                  //   UserLocalPreference.instance.storeUserId(SharePost.userId);
                  // }
                  MaterialPageRoute route = MaterialPageRoute(
                    // INIT - Get the LMFeed instance and pass the credentials (if any)
                    builder: (context) => lmFeed!,
                  );
                  Navigator.of(context).pushReplacement(route);
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
}
