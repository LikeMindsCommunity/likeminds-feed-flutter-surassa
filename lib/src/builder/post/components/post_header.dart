import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/app.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/theme/theme.dart';

Widget suraasaPostHeaderBuilder(BuildContext context, LMFeedPostHeader header,
    LMPostViewData postViewData) {
  return header.copyWith(
    subText: LMFeedText(
      text: "@${header.user.name.toLowerCase().split(' ').join()} ",
    ),
  );
}

Widget? suraasaPinPostActivityHeader(bool isPinned) {
  if (isPinned) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: kAssetPinIcon,
              style: LMFeedIconStyle.basic().copyWith(size: 18),
            ),
            LikeMindsTheme.kHorizontalPaddingMedium,
            const LMFeedText(
              text: "Pinned Post",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ],
        ),
        LikeMindsTheme.kVerticalPaddingLarge,
      ],
    );
  }
  return null;
}
