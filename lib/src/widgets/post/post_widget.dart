import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_utils.dart';
import 'package:likeminds_feed_ss_fl/src/views/likes/likes_screen.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/edit_post_screen.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/delete_dialog.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:timeago/timeago.dart' as timeago;

class SSPostWidget extends StatelessWidget {
  final Post post;
  final User user;
  final bool isFeed;
  final Function() onTap;
  final Function(bool isDeleted) refresh;
  int postLikes = 0;
  int comments = 0;
  Post? postDetails;
  bool? isLiked;
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
    NewPostBloc newPostBloc = BlocProvider.of<NewPostBloc>(context);
    timeago.setLocaleMessages('en', SSCustomMessages());
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
                  isFeed: isFeed,
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
                  createdAt: LMTextView(
                    text: timeago.format(post.createdAt),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: kGreyColor,
                    ),
                  ),
                  menu: LMPostMenu(
                    menuItems: postDetails!.menuItems,
                    onSelected: (id) {
                      if (id == 1) {
                        // Delete post
                        showDialog(
                            context: context,
                            builder: (childContext) => deleteConfirmationDialog(
                                  childContext,
                                  title: 'Delete Post',
                                  userId: postDetails!.userId,
                                  content:
                                      'Are you sure you want to delete this post. This action can not be reversed.',
                                  action: (String reason) async {
                                    Navigator.of(childContext).pop();
                                    final res =
                                        await locator<LikeMindsService>()
                                            .getMemberState();
                                    //Implement delete post analytics tracking
                                    LMAnalytics.get().track(
                                      AnalyticsKeys.postDeleted,
                                      {
                                        "user_state":
                                            res.state == 1 ? "CM" : "member",
                                        "post_id": postDetails!.id,
                                        "user_id": postDetails!.userId,
                                      },
                                    );
                                    newPostBloc.add(
                                      DeletePost(
                                        postId: postDetails!.id,
                                        reason: reason ?? 'Self Post',
                                      ),
                                    );
                                    if (!isFeed) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  actionText: 'Delete',
                                ));
                      } else if (id == 5) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditPostScreen(
                                  postId: postDetails!.id,
                                )));
                      }
                    },
                    isFeed: isFeed,
                  ),
                ),
                const SizedBox(height: 8),
                const LMPostContent(),
                postDetails!.attachments != null
                    ? const SizedBox(height: 12)
                    : const SizedBox(),
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
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LikesScreen(
                                            postId: postDetails!.id,
                                          )));
                            },
                            child: LMTextView(text: "${postLikes} Likes")),
                        const Spacer(),
                        LMTextView(text: "${post.commentCount} Comments"),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                const Divider(),
                const SizedBox(height: 6),
                LMPostFooter(
                  alignment: LMAlignment.centre,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: rebuildLikeWidget,
                        builder: (context, _, __) {
                          return LMTextButton(
                            text: const LMTextView(text: "Like"),
                            activeText: LMTextView(
                              text: "Like",
                              textStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            onTap: () async {
                              if (isLiked!) {
                                postLikes--;
                              } else {
                                postLikes++;
                              }
                              isLiked = !isLiked!;
                              rebuildLikeWidget.value =
                                  !rebuildLikeWidget.value;

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

                                if (isLiked!) {
                                  postLikes--;
                                } else {
                                  postLikes++;
                                }
                                isLiked = !isLiked!;
                                rebuildLikeWidget.value =
                                    !rebuildLikeWidget.value;
                              } else {
                                if (!isFeed) {
                                  newPostBloc
                                      .add(UpdatePost(postId: postDetails!.id));
                                }
                              }
                            },
                            icon: const LMIcon(
                              type: LMIconType.icon,
                              icon: Icons.thumb_up_alt_outlined,
                              size: 24,
                            ),
                            activeIcon: LMIcon(
                              type: LMIconType.icon,
                              icon: Icons.thumb_up_alt_sharp,
                              size: 24,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            isActive: isLiked!,
                          );
                        }),
                    // LMLikeButton(),
                    LMTextButton(
                      text: const LMTextView(text: "Comment"),
                      onTap: () {
                        if (isFeed) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                postId: post.id,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const LMIcon(
                        type: LMIconType.icon,
                        icon: Icons.message_outlined,
                        size: 24,
                      ),
                    ),
                    LMTextButton(
                      text: const LMTextView(text: "Share"),
                      onTap: () {
                        print("Share");
                      },
                      icon: const LMIcon(
                        type: LMIconType.icon,
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
