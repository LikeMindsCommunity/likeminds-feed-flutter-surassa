import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

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
  // FlickManager? flickManager;

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
        // flickManager ??= FlickManager(
        //   videoPlayerController: VideoPlayerController.network(
        //     postAttachments[i].attachmentMeta.url!,
        //   ),
        //   autoPlay: true,
        //   autoInitialize: true,
        // );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMMM d, hh:mm');
    final String formatted = formatter.format(post.createdAt);
    // setupFlickManager();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
            ValueListenableBuilder(
              valueListenable: rebuildCurr,
              builder: (context, value, child) {
                return LMTextView(
                  text:
                      '${currPosition + 1} of ${postAttachments.length} media • ${formatted}',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        color: kWhiteColor,
                      ),
                );
              },
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
                      aspectRatio: 9 / 16,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: false,
                      enlargeFactor: 0.0,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        currPosition = index;
                        if (postAttachments[index].attachmentType == 2) {
                          // if (flickManager == null) {
                          //   setupFlickManager();
                          // } else {
                          //   flickManager?.handleChangeVideo(
                          //     VideoPlayerController.network(
                          //       postAttachments[currPosition]
                          //           .attachmentMeta
                          //           .url!,
                          //     ),
                          //   );
                          // }
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

                    return Container(
                      color: Colors.black,
                      width: MediaQuery.of(context).size.width,
                      child: ExtendedImage.network(
                        postAttachments![index].attachmentMeta.url!,
                        // errorWidget: (context, url, error) =>
                        // mediaErrorWidget(),
                        // progressIndicatorBuilder: (context, url, progress) =>
                        //     LMPostShimmer(),
                        cache: true,
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (state) {
                          return GestureConfig(
                            hitTestBehavior: HitTestBehavior.opaque,
                            minScale: 0.9,
                            animationMinScale: 0.7,
                            maxScale: 3.0,
                            animationMaxScale: 3.5,
                            speed: 1.0,
                            inertialSpeed: 100.0,
                            initialScale: 1.0,
                            inPageView: true,
                            initialAlignment: InitialAlignment.center,
                          );
                        },
                      ),
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
