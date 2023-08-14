import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';

class TaggingHelper {
  static final RegExp tagRegExp = RegExp(r'@([^<>~]+)~');
  static const String notificationTagRoute =
      r'<<([^<>]+)\|route://([^<>]+)/([a-zA-Z-0-9]+)>>';
  static const String tagRoute =
      r'<<([^<>]+)\|route://member/([a-zA-Z-0-9]+)>>';
  static const String linkRoute =
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+';

  /// Encodes the string with the user tags and returns the encoded string
  static String encodeString(String string, List<UserTag> userTags) {
    final Iterable<RegExpMatch> matches = tagRegExp.allMatches(string);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final UserTag? userTag =
          userTags.firstWhereOrNull((element) => element.name! == tag);
      if (userTag != null) {
        string = string.replaceAll('@$tag~',
            '<<${userTag.name}|route://member/${userTag.userUniqueId}>>');
      }
    }
    return string;
  }

  /// Decodes the string with the user tags and returns the decoded string
  static Map<String, String> decodeString(String string) {
    Map<String, String> result = {};
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(string);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final String id = match.group(3)!;
      string = string.replaceAll('<<$tag|route://member/$id>>', '@$tag');
      result.addAll({tag: id});
    }
    return result;
  }

  static Map<String, String> decodeNotificationString(String string) {
    Map<String, String> result = {};
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(string);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      string = string.replaceAll('<<$tag|route://$mid/$id>>', '@$tag');
      result.addAll({tag: id});
    }
    return result;
  }

  /// Matches the tags in the string and returns the list of matched tags
  static List<UserTag> matchTags(String text, List<UserTag> items) {
    final List<UserTag> tags = [];
    final Iterable<RegExpMatch> matches = tagRegExp.allMatches(text);
    for (final match in matches) {
      final String tag = match.group(1)!;
      final UserTag? userTag =
          items.firstWhereOrNull((element) => element.name! == tag);
      if (userTag != null) {
        tags.add(userTag);
      }
    }
    return tags;
  }

  static void routeToProfile(String userId) {
    locator<LikeMindsService>().routeToProfile(userId);
  }

  static String convertRouteToTag(String text, {bool withTilde = true}) {
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(text);

    for (final match in matches) {
      final String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      text = text.replaceAll(
          '<<$tag|route://$mid/$id>>', withTilde ? '@$tag~' : '@$tag');
    }
    return text;
  }

  static String convertNotificationRouteToTag(String text,
      {bool withTilde = true}) {
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(text);

    for (final match in matches) {
      final String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      text = text.replaceAll('<<$tag|route://$mid/$id>>', '@$tag~');
    }
    return text;
  }

  static Map<String, dynamic> convertRouteToTagAndUserMap(String text,
      {bool withTilde = true}) {
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(text);
    List<UserTag> userTags = [];
    for (final match in matches) {
      final String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      text = text.replaceAll(
          '<<$tag|route://$mid/$id>>', withTilde ? '@$tag~' : '@$tag');
      userTags.add(UserTag(userUniqueId: id, name: tag));
    }
    return {'text': text, 'userTags': userTags};
  }

  static List<UserTag> addUserTagsIfMatched(String input) {
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(input);
    List<UserTag> userTags = [];
    for (final match in matches) {
      final String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      userTags.add(UserTag(userUniqueId: id, name: tag));
    }
    return userTags;
  }

  static List<TextSpan> extractNotificationTags(String text) {
    List<TextSpan> textSpans = [];
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(text);
    int lastIndex = 0;
    for (Match match in matches) {
      int startIndex = match.start;
      int endIndex = match.end;
      String? link = match.group(0);

      if (lastIndex != startIndex) {
        // Add a TextSpan for the preceding text
        textSpans.add(
          TextSpan(
            text: text.substring(lastIndex, startIndex),
            style: const TextStyle(
              wordSpacing: 1.5,
              color: kGrey1Color,
            ),
          ),
        );
      }
      // Add a TextSpan for the URL
      textSpans.add(
        TextSpan(
          text: TaggingHelper.decodeNotificationString(link!).keys.first,
          style: const TextStyle(
            wordSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: kGrey1Color,
          ),
        ),
      );

      lastIndex = endIndex;
    }

    if (lastIndex != text.length) {
      // Add a TextSpan for the remaining text
      textSpans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(wordSpacing: 1.5, color: kGrey1Color),
      ));
    }

    return textSpans;
  }
}

List<String> extractLinkFromString(String text) {
  RegExp exp = RegExp(TaggingHelper.linkRoute);
  Iterable<RegExpMatch> matches = exp.allMatches(text);
  List<String> links = [];
  for (var match in matches) {
    String link = text.substring(match.start, match.end);
    if (link.isNotEmpty) {
      links.add(link);
    }
  }
  if (links.isNotEmpty) {
    return links;
  } else {
    return [];
  }
}

String getFirstValidLinkFromString(String text) {
  try {
    List<String> links = extractLinkFromString(text);
    List<String> validLinks = [];
    String validLink = '';
    if (links.isNotEmpty) {
      for (String link in links) {
        if (Uri.parse(link).isAbsolute) {
          validLinks.add(link);
        } else {
          link = "https://$link";
          if (Uri.parse(link).isAbsolute) {
            validLinks.add(link);
          }
        }
      }
    }
    if (validLinks.isNotEmpty) {
      validLink = validLinks.first;
    }
    return validLink;
  } catch (e) {
    return '';
  }
}
