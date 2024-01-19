import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';

Widget suraasaPostFooterBuilder(BuildContext context,
    LMFeedPostFooter footerWidget, LMPostViewData postViewData) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          LMFeedText(
            text: LMFeedPostUtils.getLikeCountTextWithCount(
              postViewData.likeCount,
            ),
          ),
          LMFeedText(
            text:
                '${postViewData.commentCount} ${LMFeedPostUtils.getCommentCountText(
              postViewData.commentCount,
            )}',
          ),
        ],
      ),
      LMThemeData.kVerticalPaddingMedium,
      const Divider(
        height: 1,
      ),
      footerWidget.copyWith(
        likeButtonBuilder: (likeButton) {
          return suraasaLikeButtonBuilder(context, likeButton);
        },
        commentButtonBuilder: (commentButton) {
          return suraasaCommentButtonBuilder(context, commentButton);
        },
      ),
    ],
  );
}

Widget suraasaLikeButtonBuilder(BuildContext context, LMFeedButton button) {
  return button.copyWith(
    text: button.text?.copyWith(text: 'Like') ?? const LMFeedText(text: 'Like'),
  );
}

Widget suraasaCommentButtonBuilder(BuildContext context, LMFeedButton button) {
  return button.copyWith(
    text: button.text?.copyWith(text: 'Comment') ??
        const LMFeedText(text: 'Comment'),
  );
}
