import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/views/activity/activity_feed.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/packages/expandable_text/expandable_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class SSActivityWidget extends StatefulWidget {
  const SSActivityWidget({super.key, required this.uuid});
  final String uuid;

  @override
  State<SSActivityWidget> createState() => _SSActivityWidgetState();
}

class _SSActivityWidgetState extends State<SSActivityWidget> {
  GetUserActivityResponse? _activityResponse;
  final ValueNotifier<bool> _rebuildActivity = ValueNotifier(false);

  @override
  void initState() {
    loadActivity();
    super.initState();
  }

  void loadActivity() async {
    final activityRequest = (GetUserActivityRequestBuilder()
          ..uuid(widget.uuid)
          ..page(1)
          ..pageSize(10))
        .build();
    _activityResponse = await locator<LMFeedClient>().getUserActivity(
      activityRequest,
    );
    _rebuildActivity.value = !_rebuildActivity.value;
  }

  String getUserName(String actionBy) {
    if (widget.uuid ==
        _activityResponse!.users![actionBy]!.sdkClientInfo!.userUniqueId) {
      return 'You';
    } else {
      return _activityResponse!.users![actionBy]!.name;
    }
  }

  String getActivityTextWithoutName(String activityText, String actionBy) {
    final String name = getUserName(actionBy);
    return activityText.replaceFirst(name, '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: LMThemeData.onSurface),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: LMTextView(
            text: 'Activity',
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Divider(color: LMThemeData.onSurface),
        ValueListenableBuilder(
            valueListenable: _rebuildActivity,
            builder: (context, value, child) {
              return _activityResponse == null
                  ? const Center(
                      child: LMLoader(),
                    )
                  : Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: _activityResponse!.activities!.length <= 3
                              ? _activityResponse?.activities?.length
                              : 3,
                          itemBuilder: (context, index) {
                            final activity =
                                _activityResponse!.activities![index];
                            final PostViewData postData = activity.action == 7
                                ? PostViewData.fromPost(
                                    post: activity.activityEntityData.postData!)
                                : (PostViewDataBuilder()
                                      ..id(activity.activityEntityData.id)
                                      ..isEdited(
                                          activity.activityEntityData.isEdited!)
                                      ..text(activity.activityEntityData.text)
                                      ..attachments(activity
                                          .activityEntityData.attachments!)
                                      ..communityId(activity
                                          .activityEntityData.communityId)
                                      ..isPinned(
                                          activity.activityEntityData.isPinned!)
                                      ..topics(
                                          activity.activityEntityData.topics!)
                                      ..userId(
                                          activity.activityEntityData.userId!)
                                      ..likeCount(activity
                                          .activityEntityData.likesCount!)
                                      ..commentCount(activity
                                          .activityEntityData.commentsCount!)
                                      ..isSaved(
                                          activity.activityEntityData.isSaved!)
                                      ..isLiked(
                                          activity.activityEntityData.isLiked!)
                                      ..menuItems(activity
                                          .activityEntityData.menuItems!)
                                      ..createdAt(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              activity.activityEntityData
                                                  .createdAt))
                                      ..updatedAt(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              activity.activityEntityData
                                                  .updatedAt!)))
                                    .build();
                            late final VideoPlayerController controller;
                            late final Future<void> futureValue;
                            if (postData.attachments!.isNotEmpty &&
                                mapIntToMediaType(postData
                                        .attachments![0].attachmentType) ==
                                    MediaType.video) {
                              controller = VideoPlayerController.networkUrl(
                                  Uri.parse(postData
                                      .attachments![0].attachmentMeta.url!));
                              futureValue = controller.initialize();
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  SSActivityTileWidget(
                                    title: Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text:
                                                '${getUserName(activity.actionBy.first)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: LMThemeData.kGrey1Color,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    '${getActivityTextWithoutName(activity.activityText, activity.actionBy.first)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  color:
                                                      LMThemeData.kGrey1Color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: CircleAvatar(
                                            radius: 3,
                                            backgroundColor: Colors.black,
                                          ),
                                        ),
                                        LMTextView(
                                          text:
                                              '  ${timeago.format(DateTime.fromMillisecondsSinceEpoch(_activityResponse!.activities![index].createdAt))}',
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: ExpandableText(postData.text,
                                          expandText: 'Read More',
                                          maxLines: 2, onTagTap: (tag) {
                                        debugPrint(tag);
                                      }, onLinkTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PostDetailScreen(
                                              postId: postData.id,
                                            ),
                                          ),
                                        );
                                      },
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          )),
                                    ),
                                    trailing: postData
                                                .attachments!.isNotEmpty &&
                                            mapIntToMediaType(postData
                                                    .attachments![0]
                                                    .attachmentType) ==
                                                MediaType.image
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LMImage(
                                              imageUrl: postData.attachments![0]
                                                  .attachmentMeta.url,
                                              height: 64,
                                              width: 64,
                                              // borderRadius: 24,
                                              boxFit: BoxFit.cover,
                                            ),
                                          )
                                        : postData.attachments!.isNotEmpty &&
                                                mapIntToMediaType(postData
                                                        .attachments![0]
                                                        .attachmentType) ==
                                                    MediaType.video
                                            ? FutureBuilder(
                                                future: futureValue,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.done) {
                                                    return ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      child: SizedBox(
                                                        height: 64,
                                                        width: 64,
                                                        child: VideoPlayer(
                                                          controller,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return  const SizedBox(
                                                      height: 64,
                                                      width: 64,
                                                      child:LMPostMediaShimmer(),);
                                                  }
                                                },
                                              )
                                            : const SizedBox.shrink(),
                                    onTap: () {
                                      debugPrint('Activity Tapped');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetailScreen(
                                            postId: postData.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (index !=
                                      (_activityResponse!.activities!.length <=
                                              3
                                          ? (_activityResponse!
                                                  .activities!.length -
                                              1)
                                          : 2))
                                    const Divider(color: LMThemeData.onSurface),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(color: LMThemeData.onSurface),
                        LMTextButton(
                          text: const LMTextView(
                            text: 'View More Activity',
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: LMThemeData.kPrimaryColor),
                          ),
                          icon: const LMIcon(
                            type: LMIconType.icon,
                            icon: Icons.arrow_forward,
                            color: LMThemeData.kPrimaryColor,
                          ),
                          placement: LMIconPlacement.end,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SSActivityFeedScreen(
                                  uuid: widget.uuid,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
            }),
        const Divider(color: LMThemeData.onSurface)
      ],
    );
  }
}
