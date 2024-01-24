import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/comment/comment_builder.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/components/post_detail_app_bar.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/post/components/post_footer.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/post/components/post_header.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/post/components/post_topic.dart';

Widget suraasaPostWidgetBuilder(
    BuildContext context, LMFeedPostWidget postWidget, LMPostViewData postData,
    {bool isFeed = false, Widget? activityHeader}) {
  return postWidget.copyWith(
    onPostTap: (context, post) {
      if (isFeed) {
        navigateToLMPostDetailsScreen(context: context, post.id);
      }
    },
    activityHeader:
        activityHeader ?? suraasaPinPostActivityHeader(postData.isPinned),
    headerBuilder: suraasaPostHeaderBuilder,
    topicBuilder: suraasaPostTopicChipBuilder,
    footerBuilder: (context, footer, postViewData) =>
        suraasaPostFooterBuilder(context, footer, postViewData, isFeed: isFeed),
  );
}

void navigateToLMPostDetailsScreen(
  String postId, {
  GlobalKey<NavigatorState>? navigatorKey,
  BuildContext? context,
}) {
  if (context == null && navigatorKey == null) {
    throw Exception('''
Either context or navigator key must be
         provided to navigate to PostDetailScreen''');
  }
  MaterialPageRoute route = MaterialPageRoute(
    builder: (context) => LMFeedPostDetailScreen(
      postId: postId,
      postBuilder: suraasaPostWidgetBuilder,
      commentBuilder: suraasaCommentWidgetBuilder,
      appBarBuilder: suraasaPostDetailScreenAppBarBuilder,
    ),
  );
  if (navigatorKey != null) {
    navigatorKey.currentState!.push(route);
  } else {
    Navigator.push(context!, route);
  }
}
