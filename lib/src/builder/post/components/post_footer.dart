import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';

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
                style: const LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontSize: LikeMindsTheme.kFontSmallMed,
                    color: onSurface600,
                    fontWeight: FontWeight.w400,
                  ),
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
                style: const LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontSize: LikeMindsTheme.kFontSmallMed,
                    color: onSurface600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
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
              context, commentButton, postViewData,
              isFeed: isFeed);
        },
        postFooterStyle: footerWidget.postFooterStyle?.copyWith(
          showSaveButton: false,
          padding: footerWidget.postFooterStyle?.padding?.copyWith(
            bottom: 0,
          ),
        ),
      ),
    ],
  );
}

Widget suraasaLikeButtonBuilder(BuildContext context, LMFeedButton button) {
  return button.copyWith(
    text: button.text?.copyWith(text: 'Like') ?? const LMFeedText(text: 'Like'),
    onTextTap: button.onTap,
  );
}

Widget suraasaCommentButtonBuilder(
    BuildContext context, LMFeedButton button, LMPostViewData postViewData,
    {bool isFeed = true}) {
  return button.copyWith(
    text: button.text?.copyWith(text: 'Comment') ??
        const LMFeedText(text: 'Comment'),
    onTap: () {
      if (isFeed) {
        navigateToLMPostDetailsScreen(context: context, postViewData.id);
      } else {
        button.onTap.call();
      }
    },
    onTextTap: () {
      if (isFeed) {
        navigateToLMPostDetailsScreen(context: context, postViewData.id);
      } else {
        button.onTap.call();
      }
    },
  );
}
