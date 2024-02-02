import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/app.dart';
import 'package:likeminds_feed_ss_fl/src/utils/theme/theme.dart';

Widget suraasaPostFooterBuilder(BuildContext context,
    LMFeedPostFooter footerWidget, LMPostViewData postViewData,
    {bool isFeed = false}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              footerWidget.likeButton?.onTextTap?.call();
            },
            child: Container(
              color: Colors.transparent,
              child: LMFeedText(
                text: LMFeedPostUtils.getLikeCountTextWithCount(
                  postViewData.likeCount,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (isFeed) {
                navigateToLMPostDetailsScreen(postViewData.id,
                    context: context);
              }
            },
            child: Container(
              color: Colors.transparent,
              child: LMFeedText(
                text:
                    '${postViewData.commentCount} ${LMFeedPostUtils.getCommentCountText(
                  postViewData.commentCount,
                )}',
              ),
            ),
          )
        ],
      ),
      LikeMindsTheme.kVerticalPaddingMedium,
      const Divider(
        height: 1,
        color: onSurface,
      ),
      footerWidget.copyWith(
        likeButtonBuilder: (likeButton) {
          return suraasaLikeButtonBuilder(context, likeButton);
        },
        commentButtonBuilder: (commentButton) {
          return suraasaCommentButtonBuilder(
              context, commentButton, postViewData);
        },
        postFooterStyle: footerWidget.postFooterStyle?.copyWith(
          showSaveButton: false,
        ),
      ),
    ],
  );
}

Widget suraasaLikeButtonBuilder(BuildContext context, LMFeedButton button) {
  return button.copyWith(
    text: button.text?.copyWith(text: 'Like') ?? const LMFeedText(text: 'Like'),
  );
}

Widget suraasaCommentButtonBuilder(
    BuildContext context, LMFeedButton button, LMPostViewData postViewData) {
  return button.copyWith(
    text: button.text?.copyWith(text: 'Comment') ??
        const LMFeedText(text: 'Comment'),
    onTap: () {
      navigateToLMPostDetailsScreen(context: context, postViewData.id);
    },
    onTextTap: () {
      navigateToLMPostDetailsScreen(context: context, postViewData.id);
    },
  );
}
