import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/app.dart';

Widget suraasaCommentWidgetBuilder(BuildContext context,
    LMFeedCommentWidget commentWidget, LMPostViewData postViewData) {
  return commentWidget.copyWith(
    subtitleText: LMFeedText(
      text:
          '''@${commentWidget.user.name.toLowerCase().split(' ').join()} · ${LMFeedTimeAgo.instance.format(commentWidget.comment.createdAt)}''',
      style: const LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: kSecondaryColor700,
          fontFamily: 'Inter',
        ),
      ),
    ),
  );
}
