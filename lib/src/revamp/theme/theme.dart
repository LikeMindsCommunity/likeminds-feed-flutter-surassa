import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';

const Color kPrimaryColor = Color.fromRGBO(59, 130, 246, 1);
const Color primary500 = Color(0xFF4666F6);
const Color interactive100 = Color.fromRGBO(219, 234, 254, 1);
const Color kHeadingBlackColor = Color(0xFF0F172A);
const Color kPrimaryColorLight = Color(0xFFDBEAFE);
const Color kSecondary100 = Color(0xFFF1F5F9);
const Color kSecondaryColor700 = Color(0xFF334155);
const Color kSecondaryColorLight = Color(0xFFEDF0FE);
const Color onSurface = Color(0xFFE2E8F0);
const Color onSurface500 = Color.fromRGBO(100, 116, 139, 1);
const Color onSurface400 = Color.fromRGBO(148, 163, 184, 1);
const Color onSurface700 = Color.fromRGBO(51, 65, 85, 1);
const Color onSurface900 = Color.fromRGBO(15, 23, 42, 1);
const Color kBackgroundColor = Color.fromRGBO(245, 245, 245, 1);

LMFeedThemeData suraasaTheme = LMFeedThemeData.light(
  primaryColor: kPrimaryColor,
  secondaryColor: primary500,
  backgroundColor: kBackgroundColor,
  container: kBackgroundColor,
  onContainer: onSurface900,
  postStyle: LMFeedPostStyle(
    padding: const EdgeInsets.all(
      16.0,
    ),
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    boxShadow: [
      const BoxShadow(
        color: Color(0x19000000),
        blurRadius: 5,
        offset: Offset(1, 1),
      )
    ],
  ),
  topicStyle: LMFeedPostTopicStyle(
    padding: EdgeInsets.zero,
    margin: EdgeInsets.zero,
    activeChipStyle: LMFeedTopicChipStyle.active().copyWith(
      backgroundColor: primary500,
      textStyle: const TextStyle(color: LikeMindsTheme.whiteColor),
      borderRadius: BorderRadius.circular(43.0),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
    ),
    inactiveChipStyle: LMFeedTopicChipStyle.inActive().copyWith(
      textStyle: const TextStyle(color: onSurface700),
      showBorder: true,
      borderWidth: 1.0,
      borderColor: onSurface400,
      borderRadius: BorderRadius.circular(43.0),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
    ),
  ),
  contentStyle: LMFeedPostContentStyle.basic().copyWith(
    padding: const EdgeInsets.symmetric(
      vertical: 8.0,
    ),
  ),
  mediaStyle: LMFeedPostMediaStyle(
    carouselStyle: LMFeedPostCarouselStyle(
      carouselBorderRadius: BorderRadius.circular(16.0),
      carouselPadding: const EdgeInsets.only(
        bottom: 16.0,
      ),
    ),
    documentStyle: const LMFeedPostDocumentStyle(),
    imageStyle: const LMFeedPostImageStyle(),
    linkStyle: LMFeedPostLinkPreviewStyle.basic().copyWith(
      showLinkUrl: false,
      height: 238,
      imageHeight: 178,
      backgroundColor: kSecondary100,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      titleStyle: const LMFeedTextStyle(
        maxLines: 1,
        textStyle: TextStyle(
          color: onSurface900,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 0.09,
        ),
      ),
      subtitleStyle: const LMFeedTextStyle(
        maxLines: 1,
        textStyle: TextStyle(
          color: onSurface900,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    videoStyle: const LMFeedPostVideoStyle(),
  ),
  footerStyle: LMFeedPostFooterStyle.basic().copyWith(
    padding: EdgeInsets.zero,
    margin: EdgeInsets.zero,
    showSaveButton: false,
    alignment: MainAxisAlignment.spaceBetween,
    likeButtonStyle: LMFeedButtonStyle.like(
      primaryColor: primary500,
    ).copyWith(
      margin: 4.0,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetLikeIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 20,
          boxPadding: 6,
        ),
      ),
      activeIcon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetLikeFilledIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 20,
          boxPadding: 6,
          color: Colors.transparent,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
    commentButtonStyle: LMFeedButtonStyle.comment().copyWith(
      margin: 4.0,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetCommentIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 6,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
    shareButtonStyle: LMFeedButtonStyle.share().copyWith(
      margin: 4.0,
      showText: true,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetShareIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 15,
          boxPadding: 6,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
  ),
  headerStyle: LMFeedPostHeaderStyle.basic().copyWith(
    padding: const EdgeInsets.only(
      bottom: 16.0,
    ),
  ),
  commentStyle: LMFeedCommentStyle.basic().copyWith(
    showProfilePicture: true,
    showTimestamp: false,
    profilePicturePadding: const EdgeInsets.only(
      right: 8.0,
    ),
    actionsPadding: const EdgeInsets.only(
      left: 44.0,
    ),
    likeButtonStyle: LMFeedButtonStyle.like(
      primaryColor: primary500,
    ).copyWith(
      margin: 4.0,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetLikeIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 20,
          boxPadding: 6,
        ),
      ),
      activeIcon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetLikeFilledIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 20,
          boxPadding: 6,
          color: Colors.transparent,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
    replyButtonStyle: LMFeedButtonStyle.comment().copyWith(
      margin: 4.0,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetCommentIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 6,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
  ),
  replyStyle: LMFeedCommentStyle.basic(isReply: true).copyWith(
    showProfilePicture: true,
    profilePicturePadding: const EdgeInsets.only(
      right: 8.0,
    ),
    actionsPadding: const EdgeInsets.only(
      left: 44.0,
    ),
    likeButtonStyle: LMFeedButtonStyle.like(
      primaryColor: primary500,
    ).copyWith(
      margin: 4,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetLikeIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 20,
          boxPadding: 6,
        ),
      ),
      activeIcon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetLikeFilledIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 20,
          boxPadding: 6,
          color: Colors.transparent,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
    replyButtonStyle: LMFeedButtonStyle.comment().copyWith(
      margin: 4,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: kAssetCommentIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 6,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
  ),
  composeScreenStyle: LMFeedComposeScreenStyle.basic().copyWith(
    addImageIcon: const LMFeedIcon(
      type: LMFeedIconType.svg,
      assetPath: kAssetGalleryIcon,
      style: LMFeedIconStyle(
        color: kPrimaryColor,
        boxPadding: 0,
        size: 36,
      ),
    ),
    addVideoIcon: const LMFeedIcon(
      type: LMFeedIconType.svg,
      assetPath: kAssetVideoIcon,
      style: LMFeedIconStyle(
        color: kPrimaryColor,
        boxPadding: 0,
        size: 36,
      ),
    ),
    addDocumentIcon: const LMFeedIcon(
      type: LMFeedIconType.svg,
      assetPath: kAssetDocPDFIcon,
      style: LMFeedIconStyle(
        color: kPrimaryColor,
        boxPadding: 0,
        size: 36,
      ),
    ),
    mediaPadding: const EdgeInsets.only(
      left: 64,
    ),
    mediaStyle: LMFeedComposeMediaStyle.basic().copyWith(
      imageStyle: LMFeedPostImageStyle.basic().copyWith(
        height: 144,
        width: 144,
        borderRadius: BorderRadius.circular(8.0),
      ),
      videoStyle: LMFeedPostVideoStyle.basic().copyWith(
        height: 144,
        width: 144,
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
);
