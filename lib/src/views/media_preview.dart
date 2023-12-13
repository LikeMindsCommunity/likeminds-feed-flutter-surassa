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
  final int? position;

  const MediaPreview({
    Key? key,
    required this.postAttachments,
    required this.post,
    required this.user,
    this.position,
  }) : super(key: key);

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  late List<Attachment> postAttachments;
  late Post post;
  late User user;
  late int? position;

  int currPosition = 0;
  CarouselController controller = CarouselController();
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);

  bool checkIfMultipleAttachments() {
    return (postAttachments.length > 1);
  }

  @override
  void initState() {
    postAttachments = widget.postAttachments;
    post = widget.post;
    user = widget.user;
    position = widget.position;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMMM d, hh:mm');
    final String formatted = formatter.format(post.createdAt);
    final ThemeData theme = LMThemeData.suraasaTheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        leading: LMIconButton(
          onTap: (active) {
            Navigator.of(context).pop();
          },
          icon: const LMIcon(
            type: LMIconType.icon,
            color: LMThemeData.kWhiteColor,
            icon: CupertinoIcons.xmark,
            size: 28,
            boxSize: 64,
            boxPadding: 12,
          ),
        ),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LMTextView(
              text: user.name,
              textStyle: theme.textTheme.bodyMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: LMThemeData.kWhiteColor,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: rebuildCurr,
              builder: (context, value, child) {
                return LMTextView(
                  text:
                      '${currPosition + 1} of ${postAttachments.length} media • $formatted',
                  textStyle: theme.textTheme.bodyMedium!.copyWith(
                    fontSize: 12,
                    color: LMThemeData.kWhiteColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: CarouselSlider.builder(
                  options: CarouselOptions(
                      initialPage: position ?? 0,
                      aspectRatio: 9 / 16,
                      enableInfiniteScroll: false,
                      enlargeFactor: 0.0,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        currPosition = index;
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
                        postAttachments[index].attachmentMeta.url!,
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (state) {
                          return GestureConfig(
                            hitTestBehavior: HitTestBehavior.opaque,
                            minScale: 0.9,
                            animationMinScale: 0.7,
                            maxScale: 3.0,
                            animationMaxScale: 3.5,
                            inPageView: true,
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
                          ? LMThemeData.kVerticalPaddingMedium
                          : const SizedBox(),
                      checkIfMultipleAttachments()
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: postAttachments.map((url) {
                                int index = postAttachments.indexOf(url);
                                return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 7.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currPosition == index
                                        ? LMThemeData.kWhiteColor
                                        : LMThemeData.kGrey3Color,
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
