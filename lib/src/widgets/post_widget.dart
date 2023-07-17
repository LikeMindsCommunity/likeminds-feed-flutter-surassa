import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class SSPostWidget extends StatelessWidget {
  final Post post;
  final User user;
  final bool isFeed;
  final Function() onTap;
  final Function(bool isDeleted) refresh;

  int postLikes = 0;
  int comments = 0;
  Post? postDetails;
  late bool isLiked;
  ValueNotifier<bool> rebuildLikeWidget = ValueNotifier(false);

  SSPostWidget({
    Key? key,
    required this.post,
    required this.user,
    required this.onTap,
    required this.refresh,
    required this.isFeed,
  }) : super(key: key);

  void setPostDetails() {
    postDetails = post;
    postLikes = postDetails!.likeCount;
    comments = postDetails!.commentCount;
    isLiked = postDetails!.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    setPostDetails();
    return InheritedPostProvider(
      post: post,
      child: Container(
        color: kWhiteColor,
        child: GestureDetector(
          onTap: () {
            // Navigate to LMPostPage using material route
            if (isFeed) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(
                    postId: post.id,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LMPostHeader(
                  user: user,
                  titleText: LMTextView(
                    text: user.name,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subText: LMTextView(
                    text: "@${user.name.toLowerCase().split(" ").join("")}",
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: kGreyColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const LMPostContent(),
                postDetails!.attachments != null &&
                        postDetails!.attachments!.isNotEmpty
                    ? LMPostMedia(
                        attachments: postDetails!.attachments!,
                        // postId: postDetails!.id,
                      )
                    : const SizedBox(),
                const SizedBox(height: 18),
                ValueListenableBuilder(
                  valueListenable: rebuildLikeWidget,
                  builder:
                      (BuildContext context, dynamic value, Widget? child) {
                    return Row(
                      children: [
                        LMTextView(text: "${postLikes} Likes"),
                        const Spacer(),
                        LMTextView(text: "${post.commentCount} Comments"),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Divider(),
                const SizedBox(height: 6),
                LMPostFooter(
                  alignment: LMAlignment.centre,
                  children: [
                    LMTextButton(
                      text: const LMTextView(text: "Like"),
                      activeText: LMTextView(
                        text: "Like",
                        textStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onTap: (isLiked) async {
                        isLiked = !isLiked;
                        if (isLiked) {
                          postLikes--;
                        } else {
                          postLikes++;
                        }
                        rebuildLikeWidget.value = !rebuildLikeWidget.value;

                        final response = await locator<LikeMindsService>()
                            .likePost((LikePostRequestBuilder()
                                  ..postId(postDetails!.id))
                                .build());
                        if (!response.success) {
                          toast(
                            response.errorMessage ??
                                "There was an error liking the post",
                            duration: Toast.LENGTH_LONG,
                          );
                          isLiked = !isLiked;
                          if (isLiked) {
                            postLikes--;
                          } else {
                            postLikes++;
                          }
                          rebuildLikeWidget.value = !rebuildLikeWidget.value;
                        } else {
                          await refresh(false);
                        }
                      },
                      icon: const LMIcon(
                        icon: Icons.thumb_up_alt_outlined,
                        size: 24,
                      ),
                      activeIcon: LMIcon(
                        icon: Icons.thumb_up_alt_sharp,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      isActive: isLiked,
                    ),
                    // LMLikeButton(),
                    LMTextButton(
                      text: const LMTextView(text: "Comment"),
                      onTap: (active) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider<NewPostBloc>(
                              create: (context) => NewPostBloc(),
                              child: PostDetailScreen(
                                postId: post.id,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const LMIcon(
                        icon: Icons.message_outlined,
                        size: 24,
                      ),
                    ),
                    LMTextButton(
                      text: const LMTextView(text: "Share"),
                      onTap: (active) {
                        print("Share");
                      },
                      icon: const LMIcon(
                        icon: Icons.share_outlined,
                        size: 24,
                      ),
                    ),
                  ],
                  // children: [

                  // ],
                ),
                // showActions!
                // ? PostActions(
                //     postDetails: postDetails!,
                //     refresh: refresh!,
                //     isFeed: isFeed!,
                //   )
                // : const SizedBox.shrink()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
