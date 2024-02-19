import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/report_screen.dart';

Widget suraasaPostHeaderBuilder(BuildContext context, LMFeedPostHeader header,
    LMPostViewData postViewData) {
  return header.copyWith(
    titleText: LMFeedText(
      text: postViewData.user?.name ?? '',
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: LikeMindsTheme.kFontMedium,
          color: suraasaTheme.onContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    subText: LMFeedText(
      text: "@${header.user.name.toLowerCase().split(' ').join()} ",
      style: const LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: LikeMindsTheme.kFontSmallMed,
          color: onSurface600,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    subTextSeparator: const LMFeedText(
      text: "•",
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: LikeMindsTheme.kFontSmallMed,
          color: onSurface600,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    createdAt: LMFeedText(
      text: LMFeedTimeAgo.instance.format(postViewData.createdAt),
      style: const LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: LikeMindsTheme.kFontSmallMed,
          color: onSurface600,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    menuBuilder: (menu) {
      // debugPrint('--------------${menu.children?.length.toString()}------------');
      return menu.copyWith(
        removeItemIds: {LMFeedMenuAction.postEditId},
        children: {
          LMFeedMenuAction.postPinId:
              generateMenuItem(LMFeedMenuAction.postPinId),
          LMFeedMenuAction.postUnpinId:
              generateMenuItem(LMFeedMenuAction.postUnpinId),
          LMFeedMenuAction.postReportId:
              generateMenuItem(LMFeedMenuAction.postReportId),
          LMFeedMenuAction.postDeleteId:
              generateMenuItem(LMFeedMenuAction.postDeleteId),
        },
        action: menu.action?.copyWith(
          onPostReport: () {
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

Widget generateMenuItem(int menuId) {
  String text;
  String iconAssetPath;
  Color color;
  switch (menuId) {
    case LMFeedMenuAction.postPinId:
      {
        text = 'Pin';
        iconAssetPath = kAssetPinIcon;
        color = onSurface800;
      }
      break;
    case LMFeedMenuAction.postUnpinId:
      {
        text = 'Unpin';
        iconAssetPath = kAssetPinIcon;
        color = onSurface800;
      }
      break;
    case LMFeedMenuAction.postReportId:
      {
        text = 'Report';
        iconAssetPath = kAssetReportIcon;
        color = kRedColor;
      }
      break;
    case LMFeedMenuAction.postDeleteId:
      {
        text = 'Delete';
        iconAssetPath = kAssetDeleteIcon;
        color = kRedColor;
      }
      break;

    default:
      {
        text = '';
        iconAssetPath = '';
        color = Colors.black;
      }
  }

  return Container(
    width: 175,
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: Row(
      children: [
        LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: iconAssetPath,
          style: LMFeedIconStyle.basic().copyWith(
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        LMFeedText(
          text: text,
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: LikeMindsTheme.kFontSmallMed,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
