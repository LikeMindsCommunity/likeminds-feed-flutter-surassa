import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:flutter/material.dart';

class ActivityUtils {
  static const String notificationTagRoute =
      r'<<([^<>]+)\|route://([^<>]+)/([a-zA-Z-0-9_]+)>>';

  static Map<String, String> decodeNotificationString(
      String string, String currentUserId) {
    Map<String, String> result = {};
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(string);
    for (final match in matches) {
      String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      if (id == currentUserId) {
        tag = 'You';
      }
      string = string.replaceAll('<<$tag|route://$mid/$id>>', '@$tag');
      result.addAll({tag: id});
    }
    return result;
  }

  static List<TextSpan> extractNotificationTags(
      String text, String currentUserId) {
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
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: LMThemeData.kGrey1Color,
            ),
          ),
        );
      }
      // Add a TextSpan for the URL
      textSpans.add(
        TextSpan(
          text: decodeNotificationString(link!, currentUserId).keys.first,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: LMThemeData.kGrey1Color,
          ),
        ),
      );

      lastIndex = endIndex;
    }

    if (lastIndex != text.length) {
      // Add a TextSpan for the remaining text
      textSpans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: LMThemeData.kGrey1Color,
        ),
      ));
    }

    return textSpans;
  }

  static PostViewData postViewDataFromActivity(UserActivityItem activity) {
    return activity.action == 7
        ? PostViewData.fromPost(post: activity.activityEntityData.postData!)
        : (PostViewDataBuilder()
              ..id(activity.activityEntityData.id)
              ..isEdited(activity.activityEntityData.isEdited!)
              ..text(activity.activityEntityData.text)
              ..attachments(activity.activityEntityData.attachments!)
              ..communityId(activity.activityEntityData.communityId)
              ..isPinned(activity.activityEntityData.isPinned!)
              ..topics(activity.activityEntityData.topics!)
              ..userId(activity.activityEntityData.userId!)
              ..likeCount(activity.activityEntityData.likesCount!)
              ..commentCount(activity.activityEntityData.commentsCount!)
              ..isSaved(activity.activityEntityData.isSaved!)
              ..isLiked(activity.activityEntityData.isLiked!)
              ..menuItems(activity.activityEntityData.menuItems!)
              ..createdAt(DateTime.fromMillisecondsSinceEpoch(
                  activity.activityEntityData.createdAt))
              ..updatedAt(DateTime.fromMillisecondsSinceEpoch(
                  activity.activityEntityData.updatedAt!))
              ..isRepost(false)
              ..isRepostedByUser(false)
              ..repostCount(0)
              ..isDeleted(false))
            .build();
  }
}
