import 'package:flutter/foundation.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed/src/di/di_service.dart';

class LMAnalytics {
  static LMAnalytics? _instance;
  static LMAnalytics get() => _instance ??= LMAnalytics._();

  LMAnalytics._();

  void logEvent(String eventKey, Map<String, dynamic> propertiesMap) {
    debugPrint('Event: $eventKey');
    debugPrint('Params: $propertiesMap');
  }

  void track(String eventKey, Map<String, dynamic> propertiesMap) {
    logEvent(eventKey, propertiesMap);
    // TODO: Add your analytics logic here
  }
}

class AnalyticsKeys {
  static const String notificationPageOpened = 'Notification page opened';
  static const String notificationRemoved = 'Notification removed';
  static const String notificationMuted = 'Notification muted';
  static const String aboutSectionViewed = 'About section viewed';
  static const String postSectionViewed = 'Post section viewed';
  static const String activitySectionViewed = 'Activity section viewed';
  static const String savedPostViewed = 'Saved post viewed';
  static const String postCreationStarted = 'Post creation started';
  static const String clickedOnAttachment = 'Clicked on Attachment';
  static const String userTaggedInPost = 'User tagged in a post';
  static const String linkAttachedInPost = 'Link attached in the post';
  static const String imageAttachedToPost = 'Image attached to post';
  static const String videoAttachedToPost = 'Video attached to post';
  static const String documentAttachedInPost = 'Document attached in post';
  static const String postCreationCompleted = 'Post creation completed';
  static const String postPinned = 'Post pinned';
  static const String postUnpinned = 'Post unpinned';
  static const String postShared = 'Post shared';
  static const String postEdited = 'Post edited';
  static const String postReported = 'Post reported';
  static const String postDeleted = 'Post deleted';
  static const String userFollowed = 'User followed';
  static const String feedOpened = 'Feed opened';
  static const String likeListOpen = 'Like list open';
  static const String commentListOpen = 'Comment list open';
  static const String commentPosted = 'Comment posted';
  static const String commentDeleted = 'Comment deleted';
  static const String commentReported = 'Comment reported';
  static const String replyPosted = 'Reply posted';
  static const String replyDeleted = 'Reply deleted';
  static const String replyReported = 'Reply reported';
  static const String searchInitiated = 'Search initiated';
  static const String feedSearched = 'Feed searched';
  static const String searchTabClicked = 'Search tab clicked';
  static const String hashtagClicked = 'Hashtag clicked';
  static const String hashtagFeedOpened = 'Hashtag feed opened';
  static const String hashtagFollowed = 'Hashtag followed';
  static const String hashtagUnfollowed = 'Hashtag unfollowed';
  static const String hashtagReported = 'Hashtag reported';
  static const String notificationReceived = "Notification Received";
  static const String notificationClicked = "Notification Clicked";
}
