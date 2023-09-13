import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/comment/add_comment/add_comment_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/comment/add_comment_reply/add_comment_reply_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/comment/all_comments/all_comments_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/comment/comment_replies/comment_replies_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/comment/toggle_like_comment/toggle_like_comment_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/models/post_view_model.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/local_preference/user_local_preference.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_action_id.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/delete_dialog.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/post/post_widget.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/reply/comment_reply.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final bool fromCommentButton;
  const PostDetailScreen({
    super.key,
    required this.postId,
    this.fromCommentButton = false,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool keyBoardShown = false;
  late final AllCommentsBloc _allCommentsBloc;
  late final AddCommentBloc _addCommentBloc;
  late final AddCommentReplyBloc _addCommentReplyBloc;
  late final CommentRepliesBloc _commentRepliesBloc;
  late final ToggleLikeCommentBloc _toggleLikeCommentBloc;
  late final NewPostBloc newPostBloc;
  final FocusNode focusNode = FocusNode();
  TextEditingController? _commentController;
  ValueNotifier<bool> rebuildButton = ValueNotifier(false);
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  ValueNotifier<bool> rebuildReplyWidget = ValueNotifier(false);
  bool right = true;
  PostDetailResponse? postDetailResponse;
  final PagingController<int, Reply> _pagingController =
      PagingController(firstPageKey: 1);
  PostViewModel? postData;
  User currentUser = UserLocalPreference.instance.fetchUserData();

  List<UserTag> userTags = [];
  String? result = '';
  bool isEditing = false;
  bool isReplying = false;

  String? selectedCommentId;
  String? selectedUsername;
  String? selectedReplyId;

  @override
  void dispose() {
    _allCommentsBloc.close();
    _addCommentBloc.close();
    _addCommentReplyBloc.close();
    _pagingController.dispose();
    _commentController?.dispose();
    focusNode.dispose();
    rebuildButton.dispose();
    rebuildPostWidget.dispose();
    rebuildReplyWidget.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    LMAnalytics.get().track(AnalyticsKeys.commentListOpen, {
      'postId': widget.postId,
    });
    newPostBloc = BlocProvider.of<NewPostBloc>(context);
    updatePostDetails(context);
    right = checkCommentRights();
    _commentController = TextEditingController();
    if (_commentController != null) {
      _commentController!.addListener(
        () {
          if (_commentController!.text.isEmpty) {
            _commentController!.clear();
          }
        },
      );
    }
    _allCommentsBloc = AllCommentsBloc();
    _allCommentsBloc.add(GetAllComments(
        postDetailRequest: (PostDetailRequestBuilder()
              ..postId(widget.postId)
              ..page(1))
            .build(),
        forLoadMore: false));
    _addCommentBloc = AddCommentBloc();
    _addCommentReplyBloc = AddCommentReplyBloc();
    _toggleLikeCommentBloc = ToggleLikeCommentBloc();
    _commentRepliesBloc = CommentRepliesBloc();
    _addPaginationListener();
    if (widget.fromCommentButton &&
        focusNode.canRequestFocus &&
        keyBoardShown == false) {
      focusNode.requestFocus();
      keyBoardShown = true;
    }
  }

  int _page = 1;

  void _addPaginationListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _allCommentsBloc.add(
          GetAllComments(
            postDetailRequest: (PostDetailRequestBuilder()
                  ..postId(widget.postId)
                  ..page(pageKey))
                .build(),
            forLoadMore: true,
          ),
        );
      },
    );
  }

  selectCommentToEdit(String commentId, String? replyId, String text) {
    selectedCommentId = commentId;
    isEditing = true;
    selectedReplyId = replyId;
    isReplying = false;
    Map<String, dynamic> decodedComment =
        TaggingHelper.convertRouteToTagAndUserMap(text);
    userTags = decodedComment['userTags'];
    _commentController?.value = TextEditingValue(text: decodedComment['text']);
    openOnScreenKeyboard();
    rebuildReplyWidget.value = !rebuildReplyWidget.value;
  }

  deselectCommentToEdit() {
    selectedCommentId = null;
    selectedReplyId = null;
    isEditing = false;
    _commentController?.clear();
    closeOnScreenKeyboard();
    rebuildReplyWidget.value = !rebuildReplyWidget.value;
  }

  selectCommentToReply(String commentId, String username) {
    selectedCommentId = commentId;
    debugPrint(commentId);
    selectedUsername = username;
    isReplying = true;
    isEditing = false;
    openOnScreenKeyboard();
    rebuildReplyWidget.value = !rebuildReplyWidget.value;
  }

  deselectCommentToReply() {
    selectedCommentId = null;
    selectedUsername = null;
    isReplying = false;
    closeOnScreenKeyboard();
    _commentController?.clear();
    rebuildReplyWidget.value = !rebuildReplyWidget.value;
  }

  Future updatePostDetails(BuildContext context) async {
    final GetPostResponse postDetails =
        await locator<LikeMindsService>().getPost(
      (GetPostRequestBuilder()
            ..postId(widget.postId)
            ..page(1)
            ..pageSize(10))
          .build(),
    );
    if (postDetails.success) {
      postData = PostViewModel.fromPost(post: postDetails.post!);
      rebuildPostWidget.value = !rebuildPostWidget.value;
    } else {
      toast(
        postDetails.errorMessage ?? 'An error occurred',
        duration: Toast.LENGTH_LONG,
      );
    }
  }

  void increaseCommentCount() {
    postData!.commentCount = postData!.commentCount + 1;
  }

  void decreaseCommentCount() {
    if (postData!.commentCount != 0) {
      postData!.commentCount = postData!.commentCount - 1;
    }
  }

  void addCommentToList(AddCommentSuccess addCommentSuccess) {
    List<Reply>? commentItemList = _pagingController.itemList;
    commentItemList ??= [];
    if (commentItemList.length >= 10) {
      commentItemList.removeAt(9);
    }
    commentItemList.insert(0, addCommentSuccess.addCommentResponse.reply!);
    increaseCommentCount();
    rebuildPostWidget.value = !rebuildPostWidget.value;
    newPostBloc.add(
      UpdatePost(
        post: postData!,
      ),
    );
  }

  void updateCommentInList(EditCommentSuccess editCommentSuccess) {
    List<Reply>? commentItemList = _pagingController.itemList;
    commentItemList ??= [];
    int index = commentItemList.indexWhere((element) =>
        element.id == editCommentSuccess.editCommentResponse.reply!.id);
    commentItemList[index] = editCommentSuccess.editCommentResponse.reply!;
    rebuildPostWidget.value = !rebuildPostWidget.value;
  }

  addReplyToList(AddCommentReplySuccess addCommentReplySuccess) {
    List<Reply>? commentItemList = _pagingController.itemList;
    if (addCommentReplySuccess.addCommentResponse.reply!.parentComment !=
        null) {
      int index = commentItemList!.indexWhere((element) =>
          element.id ==
          addCommentReplySuccess.addCommentResponse.reply!.parentComment!.id);
      if (index != -1) {
        commentItemList[index].repliesCount =
            commentItemList[index].repliesCount + 1;
        rebuildPostWidget.value = !rebuildPostWidget.value;
      }
    }
  }

  void removeCommentFromList(String commentId) {
    List<Reply>? commentItemList = _pagingController.itemList;
    int index =
        commentItemList!.indexWhere((element) => element.id == commentId);
    if (index != -1) {
      commentItemList.removeAt(index);
      decreaseCommentCount();
      rebuildPostWidget.value = !rebuildPostWidget.value;
      newPostBloc.add(
        UpdatePost(
          post: postData!,
        ),
      );
    }
  }

  bool checkCommentRights() {
    final MemberStateResponse memberStateResponse =
        UserLocalPreference.instance.fetchMemberRights();
    if (memberStateResponse.state == 1) {
      return true;
    }
    bool memberRights = UserLocalPreference.instance.fetchMemberRight(10);
    return memberRights;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }

        return Future(() => false);
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AllCommentsBloc>(
            create: (context) => _allCommentsBloc,
          ),
          BlocProvider<AddCommentBloc>(
            create: (context) => _addCommentBloc,
          ),
          BlocProvider<AddCommentReplyBloc>(
            create: (context) => _addCommentReplyBloc,
          ),
          BlocProvider<CommentRepliesBloc>(
            create: (context) => _commentRepliesBloc,
          ),
          BlocProvider<ToggleLikeCommentBloc>(
            create: (context) => _toggleLikeCommentBloc,
          ),
        ],
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            bottomSheet: ValueListenableBuilder(
              valueListenable: rebuildPostWidget,
              builder: (context, _, __) {
                return postData == null
                    ? const SizedBox()
                    : SafeArea(
                        child: BlocConsumer<AddCommentReplyBloc,
                            AddCommentReplyState>(
                          bloc: _addCommentReplyBloc,
                          listener: (context, state) {
                            if (state is ReplyCommentCanceled) {
                              deselectCommentToReply();
                            }
                            if (state is EditCommentCanceled) {
                              deselectCommentToEdit();
                            }
                            if (state is CommentDeleted) {
                              removeCommentFromList(state.commentId);
                            }
                            if (state is EditReplyLoading) {
                              deselectCommentToEdit();
                            }
                            if (state is ReplyEditingStarted) {
                              selectCommentToEdit(
                                  state.commentId, state.replyId, state.text);
                            }
                            if (state is EditCommentLoading) {
                              deselectCommentToEdit();
                            }
                            if (state is CommentEditingStarted) {
                              selectCommentToEdit(
                                  state.commentId, null, state.text);
                            }
                            if (state is AddCommentReplySuccess) {
                              debugPrint("AddCommentReplySuccess");
                              _commentController!.clear();
                              addReplyToList(state);
                              deselectCommentToReply();
                            }
                            if (state is AddCommentReplyError) {
                              deselectCommentToReply();
                            }
                            if (state is EditCommentSuccess) {
                              updateCommentInList(state);
                            }
                            if (state is EditReplySuccess) {}
                          },
                          builder: (context, state) => Container(
                            decoration: BoxDecoration(
                              color: kWhiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                kVerticalPaddingMedium,
                                ValueListenableBuilder(
                                    valueListenable: rebuildReplyWidget,
                                    builder: (context, _, __) {
                                      return isEditing || isReplying
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              child: Row(
                                                children: [
                                                  LMTextView(
                                                    text: isEditing
                                                        ? "Editing ${selectedReplyId != null ? 'reply' : 'comment'}"
                                                        : "Replying to",
                                                    textStyle: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: kGrey1Color,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  isEditing
                                                      ? const SizedBox()
                                                      : LMTextView(
                                                          text:
                                                              selectedUsername!,
                                                          textStyle:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: kLinkColor,
                                                          ),
                                                        ),
                                                  const Spacer(),
                                                  LMIconButton(
                                                    onTap: (active) {
                                                      if (isEditing) {
                                                        if (selectedReplyId !=
                                                            null) {
                                                          _addCommentReplyBloc.add(
                                                              EditReplyCancel());
                                                        } else {
                                                          _addCommentReplyBloc.add(
                                                              EditCommentCancel());
                                                        }
                                                        deselectCommentToEdit();
                                                      } else {
                                                        deselectCommentToReply();
                                                      }
                                                    },
                                                    icon: const LMIcon(
                                                      type: LMIconType.icon,
                                                      icon: Icons.close,
                                                      color: kGreyColor,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox();
                                    }),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(24)),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  padding: const EdgeInsets.all(3.0),
                                  child: LMTextInput(
                                    profilePicture: LMProfilePicture(
                                      fallbackText: currentUser.name,
                                      imageUrl: currentUser.imageUrl,
                                      onTap: () {
                                        if (currentUser.sdkClientInfo != null) {
                                          locator<LikeMindsService>()
                                              .routeToProfile(currentUser
                                                  .sdkClientInfo!.userUniqueId);
                                        }
                                      },
                                      size: 36,
                                    ),
                                    focusNode: focusNode,
                                    enabled: right,
                                    hintText: right
                                        ? 'Write a comment'
                                        : "You do not have permission to comment.",
                                    controller: _commentController,
                                    internalPadding: 8,
                                    externalPadding: 4,
                                    borderRadius: 24,
                                    fieldColor: Colors.transparent,
                                    sendButton: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 12.0,
                                        bottom: 16,
                                      ),
                                      child: !right
                                          ? null
                                          : ValueListenableBuilder(
                                              valueListenable:
                                                  rebuildReplyWidget,
                                              builder: (context, _, __) =>
                                                  isReplying || isEditing
                                                      ? BlocConsumer<
                                                          AddCommentReplyBloc,
                                                          AddCommentReplyState>(
                                                          bloc:
                                                              _addCommentReplyBloc,
                                                          listener: (context,
                                                              state) {},
                                                          buildWhen: (previous,
                                                              current) {
                                                            if (current
                                                                is ReplyEditingStarted) {
                                                              return false;
                                                            }
                                                            if (current
                                                                is EditReplyLoading) {
                                                              return false;
                                                            }
                                                            if (current
                                                                is CommentEditingStarted) {
                                                              return false;
                                                            }
                                                            if (current
                                                                is EditCommentLoading) {
                                                              return false;
                                                            }
                                                            return true;
                                                          },
                                                          builder:
                                                              (context, state) {
                                                            if (state
                                                                is AddCommentReplyLoading) {
                                                              return const SizedBox(
                                                                height: 15,
                                                                width: 15,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                              );
                                                            }
                                                            return ValueListenableBuilder(
                                                                valueListenable:
                                                                    rebuildButton,
                                                                builder: (
                                                                  context,
                                                                  s,
                                                                  a,
                                                                ) {
                                                                  return LMTextButton(
                                                                    text:
                                                                        LMTextView(
                                                                      text:
                                                                          "Post",
                                                                      textStyle:
                                                                          TextStyle(
                                                                        color: right
                                                                            ? Theme.of(context).colorScheme.primary
                                                                            : Colors.transparent,
                                                                        fontSize:
                                                                            12.5,
                                                                      ),
                                                                    ),
                                                                    onTap: () {
                                                                      closeOnScreenKeyboard();
                                                                      String commentText = TaggingHelper.encodeString(
                                                                          _commentController!
                                                                              .text,
                                                                          userTags);
                                                                      commentText =
                                                                          commentText
                                                                              .trim();
                                                                      if (commentText
                                                                          .isEmpty) {
                                                                        toast(
                                                                            "Please write something to post");
                                                                        return;
                                                                      }

                                                                      if (isEditing) {
                                                                        if (selectedReplyId !=
                                                                            null) {
                                                                          _addCommentReplyBloc
                                                                              .add(
                                                                            EditReply(
                                                                              editCommentReplyRequest: (EditCommentReplyRequestBuilder()
                                                                                    ..postId(widget.postId)
                                                                                    ..text(commentText)
                                                                                    ..commentId(selectedCommentId!)
                                                                                    ..replyId(selectedReplyId!))
                                                                                  .build(),
                                                                            ),
                                                                          );
                                                                        } else {
                                                                          _addCommentReplyBloc
                                                                              .add(
                                                                            EditComment(
                                                                              editCommentRequest: (EditCommentRequestBuilder()
                                                                                    ..postId(widget.postId)
                                                                                    ..text(commentText)
                                                                                    ..commentId(selectedCommentId!))
                                                                                  .build(),
                                                                            ),
                                                                          );
                                                                        }
                                                                      } else {
                                                                        _addCommentReplyBloc.add(AddCommentReply(
                                                                            addCommentRequest: (AddCommentReplyRequestBuilder()
                                                                                  ..postId(widget.postId)
                                                                                  ..text(commentText)
                                                                                  ..commentId(selectedCommentId!))
                                                                                .build()));

                                                                        _commentController
                                                                            ?.clear();
                                                                      }
                                                                    },
                                                                  );
                                                                });
                                                          },
                                                        )
                                                      : BlocConsumer<
                                                          AddCommentBloc,
                                                          AddCommentState>(
                                                          bloc: _addCommentBloc,
                                                          listener:
                                                              (context, state) {
                                                            if (state
                                                                is AddCommentSuccess) {
                                                              addCommentToList(
                                                                  state);
                                                            }
                                                            if (state
                                                                is AddCommentLoading) {
                                                              deselectCommentToEdit();
                                                            }
                                                          },
                                                          builder:
                                                              (context, state) {
                                                            if (state
                                                                is AddCommentLoading) {
                                                              return const SizedBox(
                                                                height: 15,
                                                                width: 15,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                              );
                                                            }
                                                            return ValueListenableBuilder(
                                                                valueListenable:
                                                                    rebuildButton,
                                                                builder:
                                                                    (context, s,
                                                                        a) {
                                                                  return LMTextButton(
                                                                    height: 18,
                                                                    text:
                                                                        LMTextView(
                                                                      text:
                                                                          "Post",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      textStyle: TextStyle(
                                                                          fontSize:
                                                                              12.5,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .primary),
                                                                    ),
                                                                    onTap: () {
                                                                      closeOnScreenKeyboard();
                                                                      String
                                                                          commentText =
                                                                          TaggingHelper
                                                                              .encodeString(
                                                                        _commentController!
                                                                            .text,
                                                                        userTags,
                                                                      );
                                                                      commentText =
                                                                          commentText
                                                                              .trim();
                                                                      if (commentText
                                                                          .isEmpty) {
                                                                        toast(
                                                                            "Please write something to post");
                                                                        return;
                                                                      }

                                                                      if (postDetailResponse !=
                                                                          null) {
                                                                        postDetailResponse!.users?.putIfAbsent(
                                                                            currentUser
                                                                                .userUniqueId,
                                                                            () =>
                                                                                currentUser);
                                                                      }

                                                                      _addCommentBloc
                                                                          .add(
                                                                        AddComment(
                                                                          addCommentRequest: (AddCommentRequestBuilder()
                                                                                ..postId(widget.postId)
                                                                                ..text(commentText))
                                                                              .build(),
                                                                        ),
                                                                      );

                                                                      closeOnScreenKeyboard();
                                                                      _commentController
                                                                          ?.clear();
                                                                    },
                                                                  );
                                                                });
                                                          },
                                                        ),
                                            ),
                                    ),
                                  ),
                                ),
                                kVerticalPaddingLarge,
                              ],
                            ),
                          ),
                        ),
                      );
              },
            ),
            backgroundColor: kBackgroundColor,
            appBar: AppBar(
              leading: LMIconButton(
                icon: LMIcon(
                  type: LMIconType.icon,
                  icon: Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                onTap: (active) {
                  Navigator.pop(context);
                },
                containerSize: 48,
              ),
              backgroundColor: kWhiteColor,
              title: const LMTextView(
                text: "Comments",
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: kHeadingColor,
                ),
              ),
              elevation: 1,
            ),
            body: BlocConsumer<AllCommentsBloc, AllCommentsState>(
              listener: (context, state) {
                if (state is AllCommentsLoaded) {
                  _page++;
                  if (state.postDetails.postReplies!.replies.length < 10) {
                    _pagingController
                        .appendLastPage(state.postDetails.postReplies!.replies);
                  } else {
                    _pagingController.appendPage(
                        state.postDetails.postReplies!.replies, _page);
                  }
                }
              },
              bloc: _allCommentsBloc,
              builder: (context, state) {
                if (state is AllCommentsLoaded ||
                    state is PaginatedAllCommentsLoading) {
                  if (state is AllCommentsLoaded) {
                    debugPrint("AllCommentsLoaded$state");
                    postDetailResponse = state.postDetails;
                    postDetailResponse!.users!.putIfAbsent(
                        currentUser.userUniqueId, () => currentUser);
                  } else {
                    debugPrint("PaginatedAllCommentsLoading$state");
                    postDetailResponse =
                        (state as PaginatedAllCommentsLoading).prevPostDetails;
                    postDetailResponse!.users!.putIfAbsent(
                        currentUser.userUniqueId, () => currentUser);
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      await updatePostDetails(context);
                      _commentRepliesBloc.add(ClearCommentReplies());
                      _pagingController.refresh();
                      _page = 1;
                    },
                    child: ValueListenableBuilder(
                        valueListenable: rebuildPostWidget,
                        builder: (context, _, __) {
                          return BlocListener<NewPostBloc, NewPostState>(
                            bloc: newPostBloc,
                            listener: (context, state) {
                              if (state is EditPostUploaded) {
                                postData = state.postData;
                                rebuildPostWidget.value =
                                    !rebuildPostWidget.value;
                              }
                              if (state is PostUpdateState) {
                                postData = state.post;
                              }
                            },
                            child: CustomScrollView(
                              slivers: [
                                const SliverPadding(
                                    padding: EdgeInsets.only(top: 16)),
                                SliverToBoxAdapter(
                                  child: postData == null
                                      ? Center(
                                          child: CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        )
                                      : SSPostWidget(
                                          post: postData!,
                                          topics:
                                              postDetailResponse!.topics ?? {},
                                          user: postDetailResponse!.users![
                                              postDetailResponse!
                                                  .postReplies!.userId]!,
                                          onTap: () {},
                                          isFeed: false,
                                          refresh: (bool isDeleted) async {},
                                        ),
                                ),
                                const SliverPadding(
                                  padding: EdgeInsets.only(bottom: 12),
                                ),
                                postData == null
                                    ? const SliverToBoxAdapter(
                                        child: SizedBox(),
                                      )
                                    : PagedSliverList(
                                        pagingController: _pagingController,
                                        builderDelegate:
                                            PagedChildBuilderDelegate<Reply>(
                                          noMoreItemsIndicatorBuilder:
                                              (context) =>
                                                  const SizedBox(height: 75),
                                          noItemsFoundIndicatorBuilder:
                                              (context) => const Column(
                                            children: <Widget>[
                                              SizedBox(height: 42),
                                              Text(
                                                'No comment found',
                                                style: TextStyle(
                                                  fontSize: kFontMedium,
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                'Be the first one to comment',
                                                style: TextStyle(
                                                  fontSize: kFontSmall,
                                                ),
                                              ),
                                              SizedBox(height: 180),
                                            ],
                                          ),
                                          itemBuilder: (context, item, index) {
                                            bool replyShown = false;
                                            return Container(
                                              decoration: const BoxDecoration(
                                                color: kWhiteColor,
                                                border: Border(
                                                  bottom: BorderSide(
                                                    width: 0.2,
                                                    color: Colors.black45,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  StatefulBuilder(builder:
                                                      (context,
                                                          setCommentState) {
                                                    item.menuItems.removeWhere(
                                                        (element) =>
                                                            element.id ==
                                                                commentReportId ||
                                                            element.id ==
                                                                commentEditId);
                                                    return LMCommentTile(
                                                      key: ValueKey(item.id),
                                                      onTagTap:
                                                          (String userId) {
                                                        locator<LikeMindsService>()
                                                            .routeToProfile(
                                                                userId);
                                                      },
                                                      onMenuTap: (id) {
                                                        if (id == 6) {
                                                          deselectCommentToEdit();
                                                          deselectCommentToReply();
                                                          // Delete post
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (childContext) =>
                                                                      deleteConfirmationDialog(
                                                                        childContext,
                                                                        title:
                                                                            'Delete Comment',
                                                                        userId:
                                                                            item.userId,
                                                                        content:
                                                                            'Are you sure you want to delete this post. This action can not be reversed.',
                                                                        action: (String
                                                                            reason) async {
                                                                          Navigator.of(childContext)
                                                                              .pop();
                                                                          //Implement delete post analytics tracking
                                                                          LMAnalytics.get()
                                                                              .track(
                                                                            AnalyticsKeys.commentDeleted,
                                                                            {
                                                                              "post_id": widget.postId,
                                                                              "comment_id": item.id,
                                                                            },
                                                                          );
                                                                          if (postDetailResponse !=
                                                                              null) {
                                                                            postDetailResponse!.users?.putIfAbsent(currentUser.userUniqueId,
                                                                                () => currentUser);
                                                                          }
                                                                          _addCommentReplyBloc.add(DeleteComment((DeleteCommentRequestBuilder()
                                                                                ..postId(widget.postId)
                                                                                ..commentId(item.id)
                                                                                ..reason(reason.isEmpty ? "Reason for deletion" : reason))
                                                                              .build()));
                                                                        },
                                                                        actionText:
                                                                            'Delete',
                                                                      ));
                                                        } else if (id == 8) {
                                                          debugPrint(
                                                              'Editing functionality');
                                                          _addCommentReplyBloc.add(
                                                              EditCommentCancel());
                                                          _addCommentReplyBloc
                                                              .add(
                                                            EditingComment(
                                                              commentId:
                                                                  item.id,
                                                              text: item.text,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      comment: item,
                                                      user: postDetailResponse!
                                                          .users![item.userId]!,
                                                      profilePicture:
                                                          LMProfilePicture(
                                                        fallbackText:
                                                            postDetailResponse!
                                                                .users![item
                                                                    .userId]!
                                                                .name,
                                                        onTap: () {
                                                          if (postDetailResponse!
                                                                  .users![item
                                                                      .userId]!
                                                                  .sdkClientInfo !=
                                                              null) {
                                                            locator<LikeMindsService>().routeToProfile(
                                                                postDetailResponse!
                                                                    .users![item
                                                                        .userId]!
                                                                    .sdkClientInfo!
                                                                    .userUniqueId);
                                                          }
                                                        },
                                                        imageUrl:
                                                            postDetailResponse!
                                                                .users![item
                                                                    .userId]!
                                                                .imageUrl,
                                                        size: 36,
                                                      ),
                                                      subtitleText: LMTextView(
                                                        text:
                                                            "@${postDetailResponse!.users![item.userId]!.name.toLowerCase().split(' ').join()} · ${timeago.format(item.createdAt)}",
                                                        textStyle: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSecondary,
                                                        ),
                                                      ),
                                                      actionsPadding:
                                                          const EdgeInsets.only(
                                                              left: 48),
                                                      commentActions: [
                                                        LMTextButton(
                                                          margin: 10,
                                                          text: LMTextView(
                                                            text: item.likesCount ==
                                                                    0
                                                                ? "Like"
                                                                : item.likesCount ==
                                                                        1
                                                                    ? "1 Like"
                                                                    : "${item.likesCount} Likes",
                                                            textStyle: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSecondary,
                                                                fontSize: 12),
                                                          ),
                                                          activeText:
                                                              LMTextView(
                                                            text: item.likesCount ==
                                                                    0
                                                                ? "Like"
                                                                : item.likesCount ==
                                                                        1
                                                                    ? "1 Like"
                                                                    : "${item.likesCount} Likes",
                                                            textStyle: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                                fontSize: 12),
                                                          ),
                                                          onTap: () {
                                                            _toggleLikeCommentBloc
                                                                .add(
                                                              ToggleLikeComment(
                                                                toggleLikeCommentRequest:
                                                                    (ToggleLikeCommentRequestBuilder()
                                                                          ..commentId(
                                                                              item.id)
                                                                          ..postId(
                                                                              widget.postId))
                                                                        .build(),
                                                              ),
                                                            );
                                                            setCommentState(() {
                                                              if (item
                                                                  .isLiked) {
                                                                item.likesCount -=
                                                                    1;
                                                              } else {
                                                                item.likesCount +=
                                                                    1;
                                                              }
                                                              item.isLiked =
                                                                  !item.isLiked;
                                                            });
                                                          },
                                                          icon: const LMIcon(
                                                            type:
                                                                LMIconType.svg,
                                                            assetPath:
                                                                kAssetLikeIcon,
                                                            size: 20,
                                                          ),
                                                          activeIcon:
                                                              const LMIcon(
                                                            type:
                                                                LMIconType.svg,
                                                            assetPath:
                                                                kAssetLikeFilledIcon,
                                                            size: 20,
                                                          ),
                                                          isActive:
                                                              item.isLiked,
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Row(
                                                          children: [
                                                            LMTextButton(
                                                              margin: 10,
                                                              text:
                                                                  const LMTextView(
                                                                      text:
                                                                          "Reply",
                                                                      textStyle:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                      )),
                                                              onTap: () {
                                                                selectCommentToReply(
                                                                  item.id,
                                                                  postDetailResponse!
                                                                      .users![item
                                                                          .userId]!
                                                                      .name,
                                                                );
                                                              },
                                                              icon:
                                                                  const LMIcon(
                                                                type: LMIconType
                                                                    .svg,
                                                                assetPath:
                                                                    kAssetCommentIcon,
                                                                size: 20,
                                                              ),
                                                            ),
                                                            kHorizontalPaddingMedium,
                                                            item.repliesCount >
                                                                    0
                                                                ? LMTextButton(
                                                                    onTap: () {
                                                                      if (!replyShown) {
                                                                        _commentRepliesBloc.add(GetCommentReplies(
                                                                            commentDetailRequest: (GetCommentRequestBuilder()
                                                                                  ..commentId(item.id)
                                                                                  ..postId(widget.postId)
                                                                                  ..page(1))
                                                                                .build(),
                                                                            forLoadMore: true));
                                                                        replyShown =
                                                                            true;
                                                                      }
                                                                    },
                                                                    text:
                                                                        LMTextView(
                                                                      text:
                                                                          "${item.repliesCount} ${item.repliesCount > 1 ? 'Replies' : 'Reply'}",
                                                                      textStyle:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : const SizedBox()
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                  CommentReplyWidget(
                                                    onReply:
                                                        selectCommentToReply,
                                                    refresh: () {
                                                      _pagingController
                                                          .refresh();
                                                    },
                                                    postId: widget.postId,
                                                    reply: item,
                                                    user: postDetailResponse!
                                                        .users![item.userId]!,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ],
                            ),
                          );
                        }),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            )),
      ),
    );
  }

  void openOnScreenKeyboard() {
    if (focusNode.canRequestFocus) {
      focusNode.requestFocus();
      if (_commentController != null && _commentController!.text.isNotEmpty) {
        _commentController!.selection = TextSelection.fromPosition(
            TextPosition(offset: _commentController!.text.length));
      }
    }
  }

  void closeOnScreenKeyboard() {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
  }
}
