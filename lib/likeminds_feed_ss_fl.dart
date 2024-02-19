library likeminds_feed_ss_fl;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/src/builder/post/post_builder.dart';
import 'package:likeminds_feed_ss_fl/src/utils/index.dart';

export 'src/utils/index.dart';
export 'src/builder/builder.dart';
export 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart'
    hide kAssetNoPostsIcon;

class LMFeedSuraasa extends StatefulWidget {
  final String? userId;
  final String? userName;
  final Function(BuildContext)? openChatCallback;

  const LMFeedSuraasa({
    super.key,
    this.userId,
    this.userName,
    this.openChatCallback,
  });

  @override
  State<LMFeedSuraasa> createState() => _LMFeedSuraasaState();

  static Future<void> setupFeed(
      {required String apiKey,
      String? domain,
      LMFeedClient? lmFeedClient}) async {
    await LMFeedCore.instance.initialize(
      apiKey: apiKey,
      domain: domain,
      lmFeedClient: lmFeedClient,
      config: LMFeedConfig(
        composeConfig: const LMFeedComposeScreenConfig(
          topicRequiredToCreatePost: true,
        ),
      ),
    );
    LMFeedTimeAgo.instance.setDefaultTimeFormat(SuraasaCustomTimeStamps());
  }
}

class _LMFeedSuraasaState extends State<LMFeedSuraasa> {
  Future<InitiateUserResponse>? initiateUser;
  Future<MemberStateResponse>? memberState;

  @override
  void initState() {
    super.initState();
    InitiateUserRequestBuilder requestBuilder = InitiateUserRequestBuilder();
    if (widget.userId != null) {
      requestBuilder.userId(widget.userId!);
    }

    requestBuilder.userName(widget.userName ?? "User Name");

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
                              topicChipText: 'Topic',
                              topicChipStyle: suraasaTheme
                                  .topicStyle.inactiveChipStyle
                                  ?.copyWith(
                                      textStyle: const TextStyle(
                                        color: onSurface700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      icon: const LMFeedIcon(
                                        type: LMFeedIconType.icon,
                                        icon: CupertinoIcons.chevron_down,
                                        style: LMFeedIconStyle(
                                          color: onSurface700,
                                          size: 16,
                                        ),
                                      ))),
                        );
                      },
                      postBuilder: (context, postWidget, postViewData) =>
                          suraasaPostWidgetBuilder(
                        context,
                        postWidget,
                        postViewData,
                        isFeed: true,
                      ),
                      appBar: (context, appBar) {
                        return appBar.copyWith(
                            trailing: widget.openChatCallback != null
                                ? [
                                    LMFeedButton(
                                      onTap: () {
                                        widget.openChatCallback!(context);
                                      },
                                      style: const LMFeedButtonStyle(
                                        icon: LMFeedIcon(
                                          type: LMFeedIconType.svg,
                                          assetPath: kAssetChatIcon,
                                          style: LMFeedIconStyle(
                                            color: Colors.black,
                                            size: 24,
                                            boxPadding: 6,
                                            boxSize: 36,
                                          ),
                                        ),
                                      ),
                                    )
                                  ]
                                : null,
                            title: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: LMFeedText(
                                text: "Feed",
                                style: LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    color: suraasaTheme.onContainer,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            style: appBar.style?.copyWith(
                              height: 64,
                            ));
                      },
                      config: const LMFeedScreenConfig(
                        topicSelectionWidgetType: LMFeedTopicSelectionWidgetType
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
        },
      ),
    );
  }
}
