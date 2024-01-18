import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/comment/add_comment_reply/add_comment_reply_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/comment/toggle_like_comment/toggle_like_comment_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/utils/activity/activity_utils.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_action_id.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/delete_dialog.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/post/post_widget.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:timeago/timeago.dart' as timeago;

class SSActivityFeedScreen extends StatefulWidget {
  const SSActivityFeedScreen({super.key, required this.uuid});
  final String uuid;

  @override
  State<SSActivityFeedScreen> createState() => _SSActivityFeedScreenState();
}

class _SSActivityFeedScreenState extends State<SSActivityFeedScreen> {
  final PagingController<int, UserActivityItem> _pagingController =
      PagingController(firstPageKey: 1);

  GetUserActivityResponse? _userActivityResponse;

  late final AddCommentReplyBloc _addCommentReplyBloc;
  late final ToggleLikeCommentBloc _toggleLikeCommentBloc;

  @override
  void initState() {
    _addCommentReplyBloc = AddCommentReplyBloc();
    _toggleLikeCommentBloc = ToggleLikeCommentBloc();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
      // _pagingController.appendLastPage([]);
    });
    super.initState();
  }

  void _fetchPage(int pageKey) async {
    try {
      final request = (GetUserActivityRequestBuilder()
            ..uuid(widget.uuid)
            ..page(pageKey)
            ..pageSize(10))
          .build();
      _userActivityResponse =
          await locator<LMFeedClient>().getUserActivity(request);
      final isLastPage = _userActivityResponse!.activities!.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(_userActivityResponse!.activities!);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(
            _userActivityResponse!.activities!, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _addCommentReplyBloc.close();
    _toggleLikeCommentBloc.close();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LMThemeData.suraasaTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          leading: LMTextButton(
            text: const LMTextView(
              text: 'Back',
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: LMThemeData.kPrimaryColor,
              ),
            ),
            icon: const LMIcon(
                type: LMIconType.icon,
                icon: Icons.arrow_back_ios,
                size: 16,
                color: LMThemeData.kPrimaryColor),
            margin: 2,
            padding: const EdgeInsets.only(left: 4),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: const LMTextView(
            text: 'Activity',
            textStyle: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider<AddCommentReplyBloc>(
              create: (context) => _addCommentReplyBloc,
            ),
            BlocProvider<ToggleLikeCommentBloc>(
              create: (context) => _toggleLikeCommentBloc,
            ),
          ],
          child: PagedListView<int, UserActivityItem>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<UserActivityItem>(
                noItemsFoundIndicatorBuilder: (context) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LMIcon(
                      type: LMIconType.svg,
                      assetPath: kAssetNoPostsIcon,
                      size: 130,
                    ),
                    LMTextView(
                      text: 'No Posts to show',
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            }, itemBuilder: (context, item, index) {
              final PostViewData post =
                  ActivityUtils.postViewDataFromActivity(item);
              final user = _userActivityResponse!
                  .users![item.activityEntityData.userId]!;
              return Column(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      SSPostWidget(
                        post: post,
                        user: user,
                        activityHeader: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: ActivityUtils.extractNotificationTags(
                                    _userActivityResponse!.activities!
                                        .elementAt(index)
                                        .activityText,
                                    widget.uuid),
                              ),
                            ),
                            LMThemeData.kVerticalPaddingMedium,
                            const Divider(
                              color: LMThemeData.onSurface,
                              thickness: 1,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                postId: post.id,
                              ),
                            ),
                          );
                        },
                        topics: _userActivityResponse!.topics!,
                        refresh: (val) {},
                        isFeed: true,
                      ),
                    ],
                  ),
                  if (item.action == 7)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: const BoxDecoration(
                        color: LMThemeData.kWhiteColor,
                        border: Border(
                          bottom: BorderSide(
                            width: 0.2,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Divider(
                            color: LMThemeData.onSurface,
                            thickness: 1,
                          ),
                          StatefulBuilder(builder: (context, setCommentState) {
                            final commentData = item.activityEntityData;
                            commentData.menuItems!.removeWhere((element) =>
                                element.id == commentReportId ||
                                element.id == commentEditId);
                            return LMCommentTile(
                              key: ValueKey(item.id),
                              onTagTap: (String userId) {
                                locator<LMFeedClient>().routeToProfile(userId);
                              },
                              onMenuTap: (id) {
                                if (id == commentDeleteId) {
                                  showDialog(
                                      context: context,
                                      builder: (childContext) =>
                                          deleteConfirmationDialog(
                                            childContext,
                                            title: 'Delete Comment',
                                            userId: commentData.userId!,
                                            content:
                                                'Are you sure you want to delete this post. This action can not be reversed.',
                                            action: (String reason) async {
                                              Navigator.of(childContext).pop();
                                              //Implement delete post analytics tracking
                                              LMAnalytics.get().track(
                                                AnalyticsKeys.commentDeleted,
                                                {
                                                  "post_id": commentData.postId,
                                                  "comment_id": commentData.id,
                                                },
                                              );
                                              locator<LMFeedBloc>()
                                                  .lmAnalyticsBloc
                                                  .add(FireAnalyticEvent(
                                                    eventName: AnalyticsKeys
                                                        .commentDeleted,
                                                    eventProperties: {
                                                      "post_id":
                                                          commentData.postId,
                                                      "comment_id":
                                                          commentData.id,
                                                    },
                                                  ));

                                              _addCommentReplyBloc.add(DeleteComment(
                                                  (DeleteCommentRequestBuilder()
                                                        ..postId(
                                                            commentData.postId!)
                                                        ..commentId(
                                                            commentData.id)
                                                        ..reason(reason.isEmpty
                                                            ? "Reason for deletion"
                                                            : reason))
                                                      .build()));
                                            },
                                            actionText: 'Delete',
                                          ));
                                } else if (id == commentEditId) {
                                  _addCommentReplyBloc.add(EditCommentCancel());
                                  _addCommentReplyBloc.add(
                                    EditingComment(
                                      commentId: commentData.id,
                                      text: commentData.text,
                                    ),
                                  );
                                }
                              },
                              comment: Comment(
                                userId: commentData.userId!,
                                text: commentData.text,
                                level: 0,
                                likesCount: commentData.likesCount!,
                                repliesCount: commentData.replies!.length,
                                menuItems: commentData.menuItems!,
                                createdAt: commentData.createdAt,
                                updatedAt: commentData.updatedAt!,
                                isLiked: commentData.isLiked!,
                                id: commentData.id,
                                replies: commentData.replies!,
                                isEdited: commentData.isEdited!,
                                parentComment: null,
                                uuid: commentData.uuid!,
                              ),
                              user: user,
                              profilePicture: LMProfilePicture(
                                backgroundColor: LMThemeData.kPrimaryColor,
                                fallbackText: user.name,
                                onTap: () {
                                  if (user.sdkClientInfo != null) {
                                    locator<LMFeedClient>().routeToProfile(
                                        user.sdkClientInfo!.userUniqueId);
                                  }
                                },
                                imageUrl: user.imageUrl,
                                size: 36,
                              ),
                              subtitleText: LMTextView(
                                text:
                                    "@${user.name.toLowerCase().split(' ').join()} · ${timeago.format(DateTime.fromMillisecondsSinceEpoch(commentData.createdAt))}",
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: LMThemeData.kSecondaryColor700,
                                ),
                              ),
                              actionsPadding: const EdgeInsets.only(left: 48),
                              commentActions: [
                                LMTextButton(
                                  margin: 10,
                                  text: LMTextView(
                                    text: commentData.likesCount == 0
                                        ? "Like"
                                        : commentData.likesCount == 1
                                            ? "1 Like"
                                            : "${commentData.likesCount} Likes",
                                    textStyle: const TextStyle(
                                        color: LMThemeData.kSecondaryColor700,
                                        fontSize: 12),
                                  ),
                                  activeText: LMTextView(
                                    text: commentData.likesCount == 0
                                        ? "Like"
                                        : commentData.likesCount == 1
                                            ? "1 Like"
                                            : "${commentData.likesCount} Likes",
                                    textStyle: const TextStyle(
                                        color: LMThemeData.kPrimaryColor,
                                        fontSize: 12),
                                  ),
                                  onTap: () {
                                    _toggleLikeCommentBloc.add(
                                      ToggleLikeComment(
                                        toggleLikeCommentRequest:
                                            (ToggleLikeCommentRequestBuilder()
                                                  ..commentId(commentData.id)
                                                  ..postId(post.id))
                                                .build(),
                                      ),
                                    );
                                    setCommentState(() {
                                      if (commentData.isLiked!) {
                                        item.activityEntityData.likesCount =
                                            commentData.likesCount! - 1;
                                      } else {
                                        item.activityEntityData.likesCount =
                                            commentData.likesCount! + 1;
                                      }
                                      item.activityEntityData.isLiked =
                                          !commentData.isLiked!;
                                    });
                                  },
                                  icon: const LMIcon(
                                    type: LMIconType.svg,
                                    assetPath: kAssetLikeIcon,
                                    size: 20,
                                  ),
                                  activeIcon: const LMIcon(
                                    type: LMIconType.svg,
                                    assetPath: kAssetLikeFilledIcon,
                                    size: 20,
                                  ),
                                  isActive: commentData.isLiked!,
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  children: [
                                    LMTextButton(
                                      margin: 10,
                                      text: const LMTextView(
                                          text: "Reply",
                                          textStyle: TextStyle(
                                            fontSize: 12,
                                          )),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PostDetailScreen(
                                              postId: post.id,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const LMIcon(
                                        type: LMIconType.svg,
                                        assetPath: kAssetCommentIcon,
                                        size: 20,
                                      ),
                                    ),
                                    LMThemeData.kHorizontalPaddingMedium,
                                    commentData.replies!.isNotEmpty
                                        ? LMTextButton(
                                            onTap: () {},
                                            text: LMTextView(
                                              text:
                                                  "${commentData.replies!.length} ${commentData.replies!.length > 1 ? 'Replies' : 'Comment'}",
                                              textStyle: const TextStyle(
                                                color:
                                                    LMThemeData.kPrimaryColor,
                                              ),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
