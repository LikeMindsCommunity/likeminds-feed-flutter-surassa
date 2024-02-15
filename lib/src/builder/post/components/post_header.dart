import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/report_screen.dart';

Widget suraasaPostHeaderBuilder(BuildContext context, LMFeedPostHeader header,
    LMPostViewData postViewData) {
  return header.copyWith(
    subText: LMFeedText(
      text: "@${header.user.name.toLowerCase().split(' ').join()} ",
    ),
    menuBuilder: (menu) {
      return menu.copyWith(
        removeItemIds: {LMFeedMenuAction.postEditId},
        action: menu.action?.copyWith(
          onPostReport: () {
            print(menu.action?.onPostDelete != null);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReportScreen(
                  entityId: postViewData.id,
                  entityCreatorId: postViewData.userId,
                  entityType: 5,
                ),
              ),
            );
          },
        ),
      );
    },
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
