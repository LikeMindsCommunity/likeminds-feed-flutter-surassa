// import 'package:dotenv/dotenv.dart';
library likeminds_feed_ss_fl;

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/src/builder/post/post_builder.dart';

export 'src/utils/index.dart';
export 'src/builder/builder.dart';
export 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart'
    hide kAssetNoPostsIcon;

class LMFeedSuraasa extends StatefulWidget {
  final String? userId;
  final String? userName;

  const LMFeedSuraasa({
    super.key,
    this.userId,
    this.userName,
  });

  @override
  State<LMFeedSuraasa> createState() => _LMFeedSuraasaState();
}

class _LMFeedSuraasaState extends State<LMFeedSuraasa> {
  Future<InitiateUserResponse>? initiateUser;
  Future<MemberStateResponse>? memberState;

  @override
  void initState() {
    super.initState();
    // var env = DotEnv(includePlatformEnvironment: true)..load();

    InitiateUserRequestBuilder requestBuilder = InitiateUserRequestBuilder();

    if (widget.userId != null) {
      requestBuilder.userId(widget.userId!);
    }

    if (widget.userName != null) {
      requestBuilder.userName(widget.userName!);
    }

    initiateUser = LMFeedCore.instance.initiateUser(requestBuilder.build())
      ..then(
        (value) async {
          if (value.success) {
            memberState = LMFeedCore.instance.getMemberState();
          }
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return Scaffold(
      body: FutureBuilder<InitiateUserResponse>(
          future: initiateUser,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.success) {
              return FutureBuilder<MemberStateResponse>(
                  future: memberState,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.success) {
                      return LMFeedScreen(
                        topicBarBuilder: (topicBar) {
                          return topicBar.copyWith(
                            style: topicBar.style?.copyWith(
                              height: 60,
                              backgroundColor: feedTheme.backgroundColor,
                            ),
                          );
                        },
                        postBuilder: (context, postWidget, postViewData) =>
                            suraasaPostWidgetBuilder(
                          context,
                          postWidget,
                          postViewData,
                          isFeed: true,
                        ),
                        config: const LMFeedScreenConfig(
                          topicSelectionWidgetType:
                              LMFeedTopicSelectionWidgetType
                                  .showTopicSelectionBottomSheet,
                          showCustomWidget: true,
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const LMFeedLoader();
                    } else {
                      return const Center(
                        child: Text("An error occurred"),
                      );
                    }
                  });
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const LMFeedLoader();
            } else {
              return const Center(
                child: Text("Please check your internet connection"),
              );
            }
          }),
    );
  }
}
