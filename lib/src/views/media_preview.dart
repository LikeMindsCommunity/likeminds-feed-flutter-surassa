import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:video_player/video_player.dart';

class MediaPreview extends StatefulWidget {
  final List<Attachment> postAttachments;
  final Post post;
  final User user;

  const MediaPreview({
    Key? key,
    required this.postAttachments,
    required this.post,
    required this.user,
  }) : super(key: key);

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  late List<Attachment> postAttachments;
  late Post post;
  late User user;

  int currPosition = 0;
  CarouselController controller = CarouselController();
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);
  FlickManager? flickManager;

  bool checkIfMultipleAttachments() {
    return (postAttachments.length > 1);
  }

  @override
  void initState() {
    postAttachments = widget.postAttachments;
    post = widget.post;
    user = widget.user;
    super.initState();
  }

  void setupFlickManager() {
    for (int i = 0; i < postAttachments.length; i++) {
      if (postAttachments[i].attachmentType == 2) {
        flickManager ??= FlickManager(
          videoPlayerController: VideoPlayerController.network(
            postAttachments[i].attachmentMeta.url!,
          ),
          autoPlay: true,
          autoInitialize: true,
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setupFlickManager();
    return Scaffold(
      backgroundColor: kGrey1Color,
      appBar: AppBar(
        backgroundColor: kGrey1Color,
        centerTitle: false,
        leading: LMIconButton(
          onTap: (active) {
            // router.pop();
            Navigator.of(context).pop();
          },
          icon: const LMIcon(
            type: LMIconType.icon,
            color: kWhiteColor,
            icon: CupertinoIcons.xmark,
            size: 28,
            boxSize: 64,
            boxPadding: 18,
          ),
        ),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LMTextView(
              text: user.name,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kWhiteColor,
                  ),
            ),
            LMTextView(
              text:
                  '${currPosition + 1} of ${postAttachments.length} media • ${post.createdAt}',
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 12,
                    color: kWhiteColor,
                  ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Column(
          children: <Widget>[
            // LMCarousel(
            //   attachments: postAttachments,
            //   inactiveIndicator: Container(
            //     width: 8.0,
            //     height: 8.0,
            //     margin:
            //         const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            //     decoration: const BoxDecoration(
            //       borderRadius: BorderRadius.all(
            //         Radius.circular(4),
            //       ),
            //       color: kGrey3Color,
            //     ),
            //   ),
            // ),
            Expanded(
              child: CarouselSlider.builder(
                  options: CarouselOptions(
                      clipBehavior: Clip.hardEdge,
                      scrollDirection: Axis.horizontal,
                      initialPage: 0,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: false,
                      enlargeFactor: 0.0,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        currPosition = index;
                        if (postAttachments[index].attachmentType == 2) {
                          if (flickManager == null) {
                            setupFlickManager();
                          } else {
                            flickManager?.handleChangeVideo(
                              VideoPlayerController.network(
                                postAttachments[currPosition]
                                    .attachmentMeta
                                    .url!,
                              ),
                            );
                          }
                        }
                        rebuildCurr.value = !rebuildCurr.value;
                      }),
                  itemCount: postAttachments.length,
                  itemBuilder: (context, index, realIndex) {
                    if (postAttachments[index].attachmentType == 2) {
                      return LMVideo(
                        videoUrl: postAttachments[index].attachmentMeta.url,
                        showControls: true,
                      );
                    }
                    return CachedNetworkImage(
                      imageUrl: postAttachments![index].attachmentMeta.url!,
                      // errorWidget: (context, url, error) =>
                      // mediaErrorWidget(),
                      progressIndicatorBuilder: (context, url, progress) =>
                          LMPostShimmer(),
                      fit: BoxFit.contain,
                    );
                  }),
            ),
            ValueListenableBuilder(
                valueListenable: rebuildCurr,
                builder: (context, _, __) {
                  return Column(
                    children: [
                      checkIfMultipleAttachments()
                          ? kVerticalPaddingMedium
                          : const SizedBox(),
                      checkIfMultipleAttachments()
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: postAttachments!.map((url) {
                                int index = postAttachments!.indexOf(url);
                                return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 7.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currPosition == index
                                        ? kWhiteColor
                                        : kGrey3Color,
                                  ),
                                );
                              }).toList())
                          : const SizedBox(),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}
