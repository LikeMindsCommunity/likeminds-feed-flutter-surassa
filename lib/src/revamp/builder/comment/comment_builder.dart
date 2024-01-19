import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget suraasaCommentWidgetBuilder(BuildContext context,
    LMFeedCommentWidget commentWidget, LMPostViewData postViewData) {
  return commentWidget.copyWith(
    subtitleText: LMFeedText(
      text:
          "@${commentWidget.user.name.toLowerCase().split(' ').join()} · ${timeago.format(commentWidget.comment.createdAt)}",
      style: const LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: kSecondaryColor700,
        ),
      ),
    ),
  );
}
