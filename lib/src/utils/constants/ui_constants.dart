import 'package:flutter/material.dart';

class LMThemeData {
  static const Color kPrimaryColor = Color(0xFF3B82F6);
  static const Color primary500 = Color(0xFF4666F6);
  static const Color kHeadingBlackColor = Color(0xFF0F172A);
  static const Color kPrimaryColorLight = Color(0xFFDBEAFE);
  static const Color kSecondary100 = Color(0xFFF1F5F9);
  static const Color kSecondaryColor700 = Color(0xFF334155);
  static const Color kSecondaryColorLight = Color(0xFFEDF0FE);
  static const Color onSurface = Color(0xFFE2E8F0);
  static const Color onSurface500 = Color(0xFF64748B);
  static const Color kBackgroundColor = Color(0xffF5F5F5);
  static const Color kWhiteColor = Color(0xffFFFFFF);
  static const Color appBlack = Color(0xFF334155);
  static const Color appSecondaryBlack = Color(0xFF94A3B8);
  static const Color kGreyColor = Color(0xff666666);
  static const Color kGrey1Color = Color(0xff222020);
  static const Color kGrey2Color = Color(0xff504B4B);
  static const Color kGrey3Color = Color(0xff9B9B9B);
  static const Color kGreyWebBGColor = Color(0xffE6EBF5);
  static const Color kGreyBGColor = Color(0x66D0D8E2);
  static const Color kBlueGreyColor = Color(0xFF484F67);
  static const Color kLinkColor = Color(0xff007AFF);
  static const Color kHeadingColor = Color(0xff333149);
  static const Color kBorderColor = Color(0x7ED0D8E2);
  static const Color notificationRedColor = Color(0x66D0D8E2);

  
  static const double kFontSmall = 12;
  static const double kButtonFontSize = 12;
  static const double kFontXSmall = 11;
  static const double kFontSmallMed = 14;
  static const double kFontMedium = 16;
  static const double kPaddingXSmall = 2;
  static const double kPaddingSmall = 4;
  static const double kPaddingMedium = 8;
  static const double kPaddingLarge = 16;
  static const double kPaddingXLarge = 20;
  static const double kBorderRadiusXSmall = 2;
  static const double kBorderRadiusMedium = 8;
  static const SizedBox kHorizontalPaddingXLarge =
      SizedBox(width: kPaddingXLarge);
  static const SizedBox kHorizontalPaddingSmall =
      SizedBox(width: kPaddingSmall);
  static const SizedBox kHorizontalPaddingXSmall =
      SizedBox(width: kPaddingXSmall);
  static const SizedBox kHorizontalPaddingLarge =
      SizedBox(width: kPaddingLarge);
  static const SizedBox kHorizontalPaddingMedium =
      SizedBox(width: kPaddingMedium);
  static const SizedBox kVerticalPaddingXLarge =
      SizedBox(height: kPaddingXLarge);
  static const SizedBox kVerticalPaddingSmall = SizedBox(height: kPaddingSmall);
  static const SizedBox kVerticalPaddingXSmall =
      SizedBox(height: kPaddingXSmall);
  static const SizedBox kVerticalPaddingLarge = SizedBox(height: kPaddingLarge);
  static const SizedBox kVerticalPaddingMedium =
      SizedBox(height: kPaddingMedium);

  static final ThemeData suraasaTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: LMThemeData.kPrimaryColor,
      primary: LMThemeData.kPrimaryColor,
      secondary: LMThemeData.primary500,
      onSecondary: LMThemeData.kSecondaryColor700,
    ),
  );
}
