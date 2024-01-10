import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

PostViewData postViewDataFromActivity(UserActivityItem activity) {
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
                activity.activityEntityData.updatedAt!)))
          .build();
}