import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/utils/activity/activity_utils.dart';
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
  late Future<GetUserActivityResponse> _activityResponse;

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
    _activityResponse = locator<LMFeedClient>().getUserActivity(
      activityRequest,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LMThemeData.suraasaTheme,
      child: Column(
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
          FutureBuilder<GetUserActivityResponse>(
              future: _activityResponse,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final activityResponse = snapshot.data;
                  return activityResponse!.activities!.isEmpty
                      ? SizedBox.shrink()
                      : Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  activityResponse.activities!.length <= 3
                                      ? activityResponse.activities?.length
                                      : 3,
                              itemBuilder: (context, index) {
                                final activity =
                                    activityResponse.activities![index];
                                final PostViewData postData =
                                    ActivityUtils.postViewDataFromActivity(
                                        activity);
                                late final VideoPlayerController controller;
                                late final Future<void> futureValue;
                                if (postData.attachments!.isNotEmpty &&
                                    mapIntToMediaType(postData
                                            .attachments![0].attachmentType) ==
                                        MediaType.video) {
                                  controller = VideoPlayerController.networkUrl(
                                      Uri.parse(postData.attachments![0]
                                          .attachmentMeta.url!));
                                  futureValue = controller.initialize();
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      SSActivityTileWidget(
                                        title: Row(
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                              ),
                                              child: RichText(
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                  children: ActivityUtils
                                                      .extractNotificationTags(
                                                          snapshot
                                                              .data!.activities!
                                                              .elementAt(index)
                                                              .activityText,
                                                          widget.uuid),
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 8.0),
                                              child: CircleAvatar(
                                                radius: 3,
                                                backgroundColor: Colors.black,
                                              ),
                                            ),
                                            LMTextView(
                                              text:
                                                  '  ${timeago.format(DateTime.fromMillisecondsSinceEpoch(activityResponse.activities![index].createdAt))}',
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
                                                  imageUrl: postData
                                                      .attachments![0]
                                                      .attachmentMeta
                                                      .url,
                                                  height: 64,
                                                  width: 64,
                                                  // borderRadius: 24,
                                                  boxFit: BoxFit.cover,
                                                ),
                                              )
                                            : postData.attachments!
                                                        .isNotEmpty &&
                                                    mapIntToMediaType(postData
                                                            .attachments![0]
                                                            .attachmentType) ==
                                                        MediaType.video
                                                ? FutureBuilder(
                                                    future: futureValue,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          child: SizedBox(
                                                            height: 64,
                                                            width: 64,
                                                            child: VideoPlayer(
                                                              controller,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return const SizedBox(
                                                          height: 64,
                                                          width: 64,
                                                          child:
                                                              LMPostMediaShimmer(),
                                                        );
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
                                          (activityResponse
                                                      .activities!.length <=
                                                  3
                                              ? (activityResponse
                                                      .activities!.length -
                                                  1)
                                              : 2))
                                        const Divider(
                                            color: LMThemeData.onSurface),
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
                } else {
                  return const Center(child: LMLoader());
                }
              }),
          const Divider(color: LMThemeData.onSurface)
        ],
      ),
    );
  }
}
