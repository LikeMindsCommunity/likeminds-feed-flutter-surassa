import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedActivityWidgetScreen extends StatelessWidget {
  final String uuid;

  final LMFeedPostWidgetBuilder? postWidgetBuilder;
  final LMFeedPostCommentBuilder? commentWidgetBuilder;
  final LMFeedPostAppBarBuilder? appBarBuilder;

  const LMFeedActivityWidgetScreen({
    super.key,
    required this.uuid,
    this.postWidgetBuilder,
    this.commentWidgetBuilder,
    this.appBarBuilder,
  });

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return Scaffold(
      backgroundColor: feedTheme.backgroundColor,
      body: Container(
        color: feedTheme.container,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: feedTheme.onContainer.withOpacity(0.15)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: LMFeedText(
                  text: 'Activity',
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Divider(color: feedTheme.onContainer.withOpacity(0.15)),
              LMFeedActivityWidget(
                uuid: uuid,
                appBarBuilder: appBarBuilder,
                postWidgetBuilder: postWidgetBuilder,
                commentWidgetBuilder: commentWidgetBuilder,
              ),
              Divider(color: feedTheme.onContainer.withOpacity(0.15)),
            ],
          ),
        ),
      ),
    );
  }
}
