import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget suraasaPostHeaderBuilder(BuildContext context, LMFeedPostHeader header,
    LMPostViewData postViewData) {
  return Column(
    children: <Widget>[
      if (postViewData.isPinned)
        Column(
          children: [
            Row(
              children: <Widget>[
                LMFeedIcon(
                  type: LMFeedIconType.svg,
                  assetPath: kAssetPinIcon,
                  style: LMFeedIconStyle.basic().copyWith(size: 18),
                ),
                LMThemeData.kHorizontalPaddingMedium,
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
        ),
      header.copyWith(
        subText: LMFeedText(
          text: "@${header.user.name.toLowerCase().split(' ').join()} ",
        ),
      )
    ],
  );
}
