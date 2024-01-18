import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

const Color kPrimaryColor = Color(0xFF3B82F6);
const Color primary500 = Color(0xFF4666F6);
const Color kHeadingBlackColor = Color(0xFF0F172A);
const Color kPrimaryColorLight = Color(0xFFDBEAFE);
const Color kSecondary100 = Color(0xFFF1F5F9);
const Color kSecondaryColor700 = Color(0xFF334155);
const Color kSecondaryColorLight = Color(0xFFEDF0FE);
const Color onSurface = Color(0xFFE2E8F0);
const Color onSurface500 = Color(0xFF64748B);
const Color kBackgroundColor = Color(0xffF5F5F5);

LMFeedThemeData suraasaTheme = LMFeedThemeData.light(
  primaryColor: kPrimaryColor,
  secondaryColor: primary500,
  backgroundColor: kBackgroundColor,
  container: kBackgroundColor,
  onContainer: onSurface500,
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
      backgroundColor: primary500.withOpacity(0.1),
      textStyle: const TextStyle(color: kPrimaryColor),
      borderRadius: BorderRadius.circular(43.0),
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
    ),
    inactiveChipStyle: LMFeedTopicChipStyle.inActive().copyWith(
      textStyle: const TextStyle(color: onSurface500),
      showBorder: true,
      borderWidth: 1.0,
      borderColor: kSecondaryColor700,
      borderRadius: BorderRadius.circular(43.0),
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
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
    ),
    documentStyle: const LMFeedPostDocumentStyle(),
    imageStyle: const LMFeedPostImageStyle(),
    linkStyle: const LMFeedPostLinkPreviewStyle(),
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
  headerStyle: LMFeedPostHeaderStyle.basic()
      .copyWith(padding: const EdgeInsets.only(bottom: 16.0)),
  commentStyle: LMFeedCommentStyle.basic().copyWith(
    showProfilePicture: true,
  ),
);
