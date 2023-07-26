import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/comment/add_comment_reply/add_comment_reply_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/comment/comment_replies/comment_replies_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class CommentReplyWidget extends StatefulWidget {
  final String postId;
  final Reply reply;
  final User user;
  final Function() refresh;
  final Function(String commentId, String username) onReply;

  const CommentReplyWidget({
    Key? key,
    required this.reply,
    required this.user,
    required this.postId,
    required this.onReply,
    required this.refresh,
  }) : super(key: key);

  @override
  State<CommentReplyWidget> createState() => _CommentReplyWidgetState();
}

class _CommentReplyWidgetState extends State<CommentReplyWidget> {
  late final CommentRepliesBloc _commentRepliesBloc;
  ValueNotifier<bool> rebuildLikeButton = ValueNotifier(false);
  ValueNotifier<bool> rebuildReplyList = ValueNotifier(false);
  ValueNotifier<bool> rebuildReplyButton = ValueNotifier(false);

  Reply? reply;
  late final User user;
  late final String postId;
  Function()? refresh;
  int? likeCount;
  bool isLiked = false, _replyVisible = true;
  int replyCount = 0;

  void initialiseReply() {
    reply = widget.reply;
    isLiked = reply!.isLiked;
    likeCount = reply!.likesCount;
    replyCount = reply!.repliesCount;
    refresh = widget.refresh;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    postId = widget.postId;
    user = widget.user;
    _commentRepliesBloc = CommentRepliesBloc();
    initialiseReply();
    _commentRepliesBloc.add(GetCommentReplies(
        commentDetailRequest: (GetCommentRequestBuilder()
              ..commentId(reply!.id)
              ..postId(postId)
              ..page(1))
            .build(),
        forLoadMore: true));
  }

  int page = 1;

  @override
  Widget build(BuildContext context) {
    AddCommentReplyBloc addCommentReplyBloc =
        BlocProvider.of<AddCommentReplyBloc>(context);
    initialiseReply();
    return ValueListenableBuilder(
      valueListenable: rebuildReplyList,
      builder: (context, _, __) {
        return BlocConsumer(
          bloc: _commentRepliesBloc,
          builder: ((context, state) {
            if (state is CommentRepliesLoading) {
              return const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            if (state is CommentRepliesLoaded ||
                state is PaginatedCommentRepliesLoading) {
              // replies.addAll(state.commentDetails.postReplies.replies);
              List<CommentReply> replies = [];
              Map<String, User> users = {};
              if (state is CommentRepliesLoaded) {
                replies = state.commentDetails.postReplies!.replies;
                users = state.commentDetails.users!;
              } else if (state is PaginatedCommentRepliesLoading) {
                replies = state.prevCommentDetails.postReplies!.replies;
                users = state.prevCommentDetails.users!;
              }

              List<Widget> repliesW = [];
              if (_replyVisible) {
                repliesW = replies.mapIndexed((index, element) {
                  return LMReplyTile(
                    comment: element,
                    user: users[element.userId]!,
                    onMenuTap: (value) {},
                  );
                }).toList();
              } else {
                repliesW = [];
              }

              if (replies.length % 10 == 0 &&
                  _replyVisible &&
                  replies.length != reply!.repliesCount) {
                repliesW = [
                  ...repliesW,
                  replies.isEmpty
                      ? const SizedBox()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                page++;
                                _commentRepliesBloc.add(
                                  GetCommentReplies(
                                      commentDetailRequest:
                                          (GetCommentRequestBuilder()
                                                ..commentId(reply!.id)
                                                ..page(page)
                                                ..postId(postId))
                                              .build(),
                                      forLoadMore: true),
                                );
                              },
                              child: const Text(
                                'View more replies',
                                style: TextStyle(
                                  color: kBlueGreyColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              ' ${replies.length} of ${reply!.repliesCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: kGrey3Color,
                              ),
                            )
                          ],
                        )
                ];
                // replies.add();
              }
              return BlocConsumer<AddCommentReplyBloc, AddCommentReplyState>(
                bloc: addCommentReplyBloc,
                listener: (context, state) {
                  if (state is AddCommentReplySuccess) {
                    replies.insert(0, state.addCommentResponse.reply!);

                    repliesW = replies.mapIndexed(
                      (index, element) {
                        return LMReplyTile(
                          comment: element,
                          user: users[element.userId]!,
                          onMenuTap: (value) {},
                        );
                      },
                    ).toList();
                    if (replies.isNotEmpty &&
                        replies.length % 10 == 0 &&
                        _replyVisible &&
                        replies.length != reply!.repliesCount) {
                      repliesW = [
                        ...repliesW,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                page++;
                                _commentRepliesBloc.add(GetCommentReplies(
                                    commentDetailRequest:
                                        (GetCommentRequestBuilder()
                                              ..commentId(reply!.id)
                                              ..page(page)
                                              ..postId(postId))
                                            .build(),
                                    forLoadMore: true));
                              },
                              child: const Text(
                                'View more replies',
                                style: TextStyle(
                                  color: kBlueGreyColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              ' ${replies.length} of ${reply!.repliesCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: kGrey3Color,
                              ),
                            )
                          ],
                        )
                      ];
                      // replies.add();
                    }
                  }
                  if (state is EditReplySuccess) {
                    int index = replies.indexWhere((element) =>
                        element.id == state.editCommentReplyResponse.reply!.id);
                    if (index != -1) {
                      replies[index] = state.editCommentReplyResponse.reply!;

                      if (_replyVisible) {
                        repliesW = replies.mapIndexed((index, element) {
                          return LMReplyTile(
                            comment: element,
                            user: users[element.userId]!,
                            onMenuTap: (value) {},
                          );
                        }).toList();
                      } else {
                        repliesW = [];
                      }

                      if (replies.isNotEmpty &&
                          replies.length % 10 == 0 &&
                          _replyVisible &&
                          replies.length != reply!.repliesCount) {
                        repliesW = [
                          ...repliesW,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  page++;
                                  _commentRepliesBloc.add(GetCommentReplies(
                                      commentDetailRequest:
                                          (GetCommentRequestBuilder()
                                                ..commentId(reply!.id)
                                                ..page(page)
                                                ..postId(postId))
                                              .build(),
                                      forLoadMore: true));
                                },
                                child: const Text(
                                  'View more replies',
                                  style: TextStyle(
                                    color: kBlueGreyColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                ' ${replies.length} of ${reply!.repliesCount}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kGrey3Color,
                                ),
                              )
                            ],
                          )
                        ];
                        // replies.add();
                      }
                    }
                  }
                  if (state is CommentReplyDeleted) {
                    int index = replies
                        .indexWhere((element) => element.id == state.replyId);
                    if (index != -1) {
                      replies.removeAt(index);
                      reply!.repliesCount -= 1;
                      replyCount = reply!.repliesCount;
                      rebuildReplyButton.value = !rebuildReplyButton.value;
                      if (_replyVisible) {
                        repliesW = replies.mapIndexed((index, element) {
                          return LMReplyTile(
                            comment: element,
                            user: users[element.userId]!,
                            onMenuTap: (value) {},
                          );
                        }).toList();
                      } else {
                        repliesW = [];
                      }

                      if (replies.isNotEmpty &&
                          replies.length % 10 == 0 &&
                          _replyVisible &&
                          replies.length != reply!.repliesCount) {
                        repliesW = [
                          ...repliesW,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  page++;
                                  _commentRepliesBloc.add(GetCommentReplies(
                                      commentDetailRequest:
                                          (GetCommentRequestBuilder()
                                                ..commentId(reply!.id)
                                                ..page(page)
                                                ..postId(postId))
                                              .build(),
                                      forLoadMore: true));
                                },
                                child: const Text(
                                  'View more replies',
                                  style: TextStyle(
                                    color: kBlueGreyColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                ' ${replies.length} of ${reply!.repliesCount}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kGrey3Color,
                                ),
                              )
                            ],
                          )
                        ];
                        // replies.add();
                      }
                    }
                  }
                },
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.only(
                      left: 48,
                      top: 8,
                      bottom: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: repliesW,
                    ),
                  );
                },
              );
            }
            return Container();
          }),
          listener: (context, state) {
            List<CommentReply> replies = [];
            if (state is CommentRepliesLoaded) {
              replies = state.commentDetails.postReplies!.replies;
            } else if (state is PaginatedCommentRepliesLoading) {
              replies = state.prevCommentDetails.postReplies!.replies;
            }
            replyCount = replies.length;
            rebuildReplyButton.value = !rebuildReplyButton.value;
          },
        );
      },
    );
  }
}
