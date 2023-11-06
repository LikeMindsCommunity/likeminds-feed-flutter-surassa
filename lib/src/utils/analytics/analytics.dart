import 'package:flutter/foundation.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed/src/di/di_service.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMAnalytics {
  static LMAnalytics? _instance;

  static LMAnalytics get() => _instance ??= LMAnalytics._();

  LMSDKCallback? sdkCallback;

  LMAnalytics._();


  void initialize() {
    sdkCallback =
        DIService.getIt.isRegistered<LMSDKCallback>(instanceName: "LMCallback")
            ? DIService.getIt.get<LMSDKCallback>(
                instanceName: "LMCallback",
              )
            : null;
    debugPrint("Analytics initialized");
  }

  void logEvent(String eventKey, Map<String, dynamic> propertiesMap) {
    debugPrint('Event: $eventKey');
    debugPrint('Params: $propertiesMap');
  }

  void track(String eventKey, Map<String, dynamic> propertiesMap) {
    logEvent(eventKey, propertiesMap);
    sdkCallback?.eventFiredCallback(eventKey, propertiesMap);
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

// Creates a map of properties for the post creation completed event
// This event is fired when the user clicks on the post button

void sendPostCreationCompletedEvent(List<MediaModel> postMedia,
    List<UserTag> usersTagged, List<TopicUI> topics) {
  Map<String, String> propertiesMap = {};

  if (postMedia.isNotEmpty) {
    if (postMedia.first.mediaType == MediaType.link) {
      propertiesMap['link_attached'] = 'yes';
      propertiesMap['link'] =
          postMedia.first.ogTags?.url ?? postMedia.first.link!;
    } else {
      propertiesMap['link_attached'] = 'no';
      int imageCount = 0;
      int videoCount = 0;
      int documentCount = 0;
      for (MediaModel media in postMedia) {
        if (media.mediaType == MediaType.image) {
          imageCount++;
        } else if (media.mediaType == MediaType.video) {
          videoCount++;
        } else if (media.mediaType == MediaType.document) {
          documentCount++;
        }
      }
      if (imageCount > 0) {
        propertiesMap['image_attached'] = 'yes';
        propertiesMap['image_count'] = imageCount.toString();
      } else {
        propertiesMap['image_attached'] = 'no';
      }
      if (videoCount > 0) {
        propertiesMap['video_attached'] = 'yes';
        propertiesMap['video_count'] = videoCount.toString();
      } else {
        propertiesMap['video_attached'] = 'no';
      }

      if (documentCount > 0) {
        propertiesMap['document_attached'] = 'yes';
        propertiesMap['document_count'] = documentCount.toString();
      } else {
        propertiesMap['document_attached'] = 'no';
      }
    }
  }

  if (usersTagged.isNotEmpty) {
    int taggedUserCount = 0;
    List<String> taggedUserId = [];

    taggedUserCount = usersTagged.length;
    taggedUserId = usersTagged
        .map((e) => e.sdkClientInfo?.userUniqueId ?? e.userUniqueId!)
        .toList();

    propertiesMap['user_tagged'] = taggedUserCount == 0 ? 'no' : 'yes';
    if (taggedUserCount > 0) {
      propertiesMap['tagged_users_count'] = taggedUserCount.toString();
      propertiesMap['tagged_users_id'] = taggedUserId.join(',');
    }
  }

  if (topics.isNotEmpty) {
    propertiesMap['topics_added'] = 'yes';
    propertiesMap['topics'] = topics.map((e) => e.id).toList().join(',');
  } else {
    propertiesMap['topics_added'] = 'no';
  }

  LMAnalytics.get().track(AnalyticsKeys.postCreationCompleted, propertiesMap);
}
