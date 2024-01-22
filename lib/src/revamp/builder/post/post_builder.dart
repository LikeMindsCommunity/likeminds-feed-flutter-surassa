import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/comment/comment_builder.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/post/components/post_footer.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/post/components/post_header.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/post/components/post_topic.dart';

Widget suraasaPostWidgetBuilder(
    BuildContext context, LMFeedPostWidget postWidget, LMPostViewData postData,
    {bool isFeed = false}) {
  return postWidget.copyWith(
    onPostTap: (context, post) {
      if (isFeed) {
        navigateToLMPostDetailsScreen(context, post);
      }
    },
    headerBuilder: suraasaPostHeaderBuilder,
    topicBuilder: suraasaPostTopicChipBuilder,
    footerBuilder: suraasaPostFooterBuilder,
  );
}

void navigateToLMPostDetailsScreen(BuildContext context, LMPostViewData post) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LMFeedPostDetailScreen(
        postId: post.id,
        postBuilder: suraasaPostWidgetBuilder,
        commentBuilder: suraasaCommentWidgetBuilder,
      ),
    ),
  );
}
