import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:likeminds_feed/likeminds_feed.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/simple_bloc_observer.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/universal_feed/universal_feed_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/models/post_view_model.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/utils.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/new_post_screen.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/post/post_something.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/post/post_widget.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/topic/topic_bottom_sheet.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class UniversalFeedScreen extends StatefulWidget {
  final Function(BuildContext context)? openChatCallback;
  const UniversalFeedScreen({
    this.openChatCallback,
    super.key,
  });

  @override
  State<UniversalFeedScreen> createState() => _UniversalFeedScreenState();
}

class _UniversalFeedScreenState extends State<UniversalFeedScreen> {
  /* 
  * defines the height of topic feed bar
  * initialy set to 0, after fetching the topics
  * it is set to 62 if the topics are not empty
  */
  double height = 0;
  final ScrollController _controller = ScrollController();
  // notifies value listenable builder to rebuild the topic feed
  ValueNotifier<bool> rebuildTopicFeed = ValueNotifier(false);
  // future to get the topics
  Future<GetTopicsResponse>? getTopicsResponse;
  // list of selected topics by the user
  List<TopicViewModel> selectedTopics = [];

  // bloc to handle universal feed
  late final UniversalFeedBloc _feedBloc; // bloc to fetch the feedroom data
  bool isCm = UserLocalPreference.instance
      .fetchMemberState(); // whether the logged in user is a community manager or not

  User user = UserLocalPreference.instance.fetchUserData();

  // future to get the unread notification count
  late Future<GetUnreadNotificationCountResponse> getUnreadNotificationCount;

  // used to rebuild the appbar
  final ValueNotifier _rebuildAppBar = ValueNotifier(false);

  // to control paging on FeedRoom View
  final PagingController<int, PostViewModel> _pagingController =
      PagingController(firstPageKey: 1);

  final ValueNotifier postSomethingNotifier = ValueNotifier(false);
  bool userPostingRights = true;
  var iconContainerHeight = 88.00;

  @override
  void initState() {
    super.initState();
    _addPaginationListener();
    getTopicsResponse = locator<LikeMindsService>().getTopics(
      (GetTopicsRequestBuilder()
            ..page(1)
            ..pageSize(20))
          .build(),
    );
    Bloc.observer = SimpleBlocObserver();
    _feedBloc = UniversalFeedBloc();
    _feedBloc.add(GetUniversalFeed(offset: 1, topics: selectedTopics));
    updateUnreadNotificationCount();
    _controller.addListener(_scrollListener);
    userPostingRights = checkPostCreationRights();
  }

  bool checkPostCreationRights() {
    final MemberStateResponse memberStateResponse =
        UserLocalPreference.instance.fetchMemberRights();
    if (memberStateResponse.state == 1) {
      return true;
    }
    final memberRights = UserLocalPreference.instance.fetchMemberRight(9);
    return memberRights;
  }

  void _scrollListener() {
    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (iconContainerHeight != 0) {
        iconContainerHeight = 0;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
    if (_controller.position.userScrollDirection == ScrollDirection.forward) {
      if (iconContainerHeight == 0) {
        iconContainerHeight = 88.0;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
  }

  void updateSelectedTopics(List<TopicViewModel> topics) {
    selectedTopics = topics;
    rebuildTopicFeed.value = !rebuildTopicFeed.value;
    clearPagingController();
    _feedBloc.add(
      GetUniversalFeed(
        offset: 1,
        topics: selectedTopics,
      ),
    );
  }

  // This function fetches the unread notification count
  // and updates the respective future
  void updateUnreadNotificationCount() async {
    getUnreadNotificationCount =
        locator<LikeMindsService>().getUnreadNotificationCount();
    await getUnreadNotificationCount;
    _rebuildAppBar.value = !_rebuildAppBar.value;
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _rebuildAppBar.dispose();
    _feedBloc.close();
    super.dispose();
  }

  void _scrollToTop() {
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  int _pageFeed = 1; // current index of FeedRoom

  void _addPaginationListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _feedBloc.add(
          GetUniversalFeed(
            offset: pageKey,
            topics: selectedTopics,
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(Object? state) {
    if (state is UniversalFeedLoaded) {
      _pageFeed++;
      List<PostViewModel> listOfPosts =
          state.feed.posts.map((e) => PostViewModel.fromPost(post: e)).toList();
      if (state.feed.posts.length < 10) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, _pageFeed);
      }
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
    _pageFeed = 1;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        centerTitle: false,
        title: GestureDetector(
          onTap: () {
            _scrollToTop();
          },
          child: const LMTextView(
            text: "Feed",
            textAlign: TextAlign.start,
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        elevation: 1,
        actions: [
          if (widget.openChatCallback != null)
            LMIconButton(
              containerSize: 42,
              onTap: (active) {
                widget.openChatCallback!(context);
              },
              icon: const LMIcon(
                type: LMIconType.svg,
                assetPath: kAssetChatIcon,
                color: Colors.black,
                size: 24,
                boxPadding: 6,
                boxSize: 36,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refresh();
          clearPagingController();
        },
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: postSomethingNotifier,
              builder: (context, _, __) {
                return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: iconContainerHeight,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(),
                    child: PostSomething(
                      enabled: userPostingRights,
                    ));
              },
            ),
            ValueListenableBuilder(
                valueListenable: rebuildTopicFeed,
                builder: (context, _, __) {
                  return FutureBuilder<GetTopicsResponse>(
                      future: getTopicsResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          height = 0;
                        } else if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.success == true) {
                          if (snapshot.data!.topics!.isNotEmpty) {
                            height = 50;
                          } else {
                            height = 0;
                          }
                        }
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: height,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  elevation: 5,
                                  isDismissible: true,
                                  backgroundColor: kWhiteColor,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(28.0),
                                      topRight: Radius.circular(28.0),
                                    ),
                                  ),
                                  enableDrag: true,
                                  clipBehavior: Clip.hardEdge,
                                  builder: (context) => TopicBottomSheet(
                                    selectedTopics: selectedTopics,
                                    onTopicSelected:
                                        (updatedTopics, tappedTopic) {
                                      updateSelectedTopics(updatedTopics);
                                    },
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  selectedTopics.isEmpty
                                      ? LMTopicChip(
                                          topic: TopicViewModel(
                                              name: "Topic",
                                              id: "0",
                                              isEnabled: true),
                                          borderRadius: 20.0,
                                          borderWidth: 1,
                                          showBorder: true,
                                          borderColor: appSecondaryBlack,
                                          textStyle: const TextStyle(
                                            color: appBlack,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 4.0),
                                          icon: const LMIcon(
                                            type: LMIconType.icon,
                                            icon: CupertinoIcons.chevron_down,
                                            size: 16,
                                            color: appBlack,
                                          ),
                                        )
                                      : selectedTopics.length == 1
                                          ? LMTopicChip(
                                              topic: TopicViewModel(
                                                name: selectedTopics.first.name,
                                                id: selectedTopics.first.id,
                                                isEnabled: selectedTopics
                                                    .first.isEnabled,
                                              ),
                                              borderRadius: 20.0,
                                              showBorder: false,
                                              backgroundColor:
                                                  theme.colorScheme.secondary,
                                              textStyle: const TextStyle(
                                                color: kWhiteColor,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 4.0),
                                              icon: const LMIcon(
                                                type: LMIconType.icon,
                                                icon:
                                                    CupertinoIcons.chevron_down,
                                                size: 16,
                                                color: kWhiteColor,
                                              ),
                                            )
                                          : LMTopicChip(
                                              topic: TopicViewModel(
                                                  name: "Topics",
                                                  id: "0",
                                                  isEnabled: true),
                                              borderRadius: 20.0,
                                              showBorder: false,
                                              backgroundColor:
                                                  theme.colorScheme.secondary,
                                              textStyle: const TextStyle(
                                                color: kWhiteColor,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 4.0),
                                              icon: Row(
                                                children: [
                                                  kHorizontalPaddingXSmall,
                                                  Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 4),
                                                    decoration: ShapeDecoration(
                                                      color: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4)),
                                                    ),
                                                    child: Text(
                                                      selectedTopics.length
                                                          .toString(),
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF4666F6),
                                                        fontSize: 12,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        height: 1.30,
                                                        letterSpacing: -0.48,
                                                      ),
                                                    ),
                                                  ),
                                                  kHorizontalPaddingSmall,
                                                  const LMIcon(
                                                    type: LMIconType.icon,
                                                    icon: CupertinoIcons
                                                        .chevron_down,
                                                    size: 16,
                                                    color: kWhiteColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }),
            Expanded(
              child: BlocConsumer(
                bloc: _feedBloc,
                buildWhen: (prev, curr) {
                  // Prevents changin the state while paginating the feed
                  if (prev is UniversalFeedLoaded &&
                      (curr is PaginatedUniversalFeedLoading ||
                          curr is UniversalFeedLoading)) {
                    return false;
                  }
                  return true;
                },
                listener: (context, state) => updatePagingControllers(state),
                builder: ((context, state) {
                  if (state is UniversalFeedLoaded) {
                    // Log the event in the analytics
                    return FeedRoomView(
                      isCm: isCm,
                      feedResponse: state.feed,
                      feedRoomPagingController: _pagingController,
                      user: user,
                      onRefresh: refresh,
                      scrollController: _controller,
                    );
                  } else if (state is UniversalFeedError) {
                    return FeedRoomErrorView(message: state.message);
                  }
                  return const Scaffold(
                    backgroundColor: kBackgroundColor,
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedRoomErrorView extends StatelessWidget {
  final String message;
  const FeedRoomErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor, body: Center(child: Text(message)));
  }
}

class FeedRoomView extends StatefulWidget {
  final bool isCm;
  final User user;
  final GetFeedResponse feedResponse;
  final PagingController<int, PostViewModel> feedRoomPagingController;
  final ScrollController scrollController;
  final VoidCallback onRefresh;

  const FeedRoomView({
    super.key,
    required this.isCm,
    required this.feedResponse,
    required this.feedRoomPagingController,
    required this.user,
    required this.onRefresh,
    required this.scrollController,
  });

  @override
  State<FeedRoomView> createState() => _FeedRoomViewState();
}

class _FeedRoomViewState extends State<FeedRoomView> {
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier postUploading = ValueNotifier(false);
  ScrollController? _controller;
  final ValueNotifier postSomethingNotifier = ValueNotifier(false);
  bool right = true;

  Widget getLoaderThumbnail(MediaModel? media) {
    if (media != null) {
      if (media.mediaType == MediaType.image) {
        return Image.file(
          media.mediaFile!,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
        );
      } else if (media.mediaType == MediaType.document) {
        return const LMIcon(
          type: LMIconType.svg,
          assetPath: kAssetPDFIcon,
          size: 35,
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool checkPostCreationRights() {
    final MemberStateResponse memberStateResponse =
        UserLocalPreference.instance.fetchMemberRights();
    if (memberStateResponse.state == 1) {
      return true;
    }
    final memberRights = UserLocalPreference.instance.fetchMemberRight(9);
    return memberRights;
  }

  var iconContainerHeight = 90.00;
  @override
  void initState() {
    super.initState();
    LMAnalytics.get()
        .track(AnalyticsKeys.feedOpened, {'feed_type': "universal_feed"});
    _controller = widget.scrollController..addListener(_scrollListener);
    right = checkPostCreationRights();
  }

  void _scrollListener() {
    if (_controller != null &&
        _controller!.position.userScrollDirection == ScrollDirection.reverse) {
      if (iconContainerHeight != 0) {
        iconContainerHeight = 0;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
    if (_controller != null &&
        _controller!.position.userScrollDirection == ScrollDirection.forward) {
      if (iconContainerHeight == 0) {
        iconContainerHeight = 90.0;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    NewPostBloc newPostBloc = BlocProvider.of<NewPostBloc>(context);
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          BlocConsumer<NewPostBloc, NewPostState>(
            bloc: newPostBloc,
            listener: (prev, curr) {
              if (curr is PostDeleted) {
                List<PostViewModel>? feedRoomItemList =
                    widget.feedRoomPagingController.itemList;
                feedRoomItemList?.removeWhere((item) => item.id == curr.postId);
                widget.feedRoomPagingController.itemList = feedRoomItemList;
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
              if (curr is NewPostUploading || curr is EditPostUploading) {
                // if current state is uploading
                // change postUploading flag to true
                // to block new post creation
                postUploading.value = true;
              }
              if (prev is NewPostUploading || prev is EditPostUploading) {
                // if state has changed from uploading
                // change postUploading flag to false
                // to allow new post creation
                postUploading.value = false;
              }
              if (curr is NewPostUploaded) {
                PostViewModel? item = curr.postData;
                int length =
                    widget.feedRoomPagingController.itemList?.length ?? 0;
                List<PostViewModel> feedRoomItemList =
                    widget.feedRoomPagingController.itemList ?? [];
                for (int i = 0; i < feedRoomItemList.length; i++) {
                  if (!feedRoomItemList[i].isPinned) {
                    feedRoomItemList.insert(i, item);
                    break;
                  }
                }
                if (length == feedRoomItemList.length) {
                  feedRoomItemList.add(item);
                }
                if (feedRoomItemList.isNotEmpty &&
                    feedRoomItemList.length > 10) {
                  feedRoomItemList.removeLast();
                }
                widget.feedResponse.users.addAll(curr.userData);
                widget.feedResponse.topics.addAll(curr.topics);
                widget.feedRoomPagingController.itemList = feedRoomItemList;
                postUploading.value = false;
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
              if (curr is EditPostUploaded) {
                PostViewModel? item = curr.postData;
                List<PostViewModel>? feedRoomItemList =
                    widget.feedRoomPagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == item.id) ??
                    -1;
                if (index != -1) {
                  feedRoomItemList?[index] = item;
                }
                widget.feedResponse.users.addAll(curr.userData);
                widget.feedResponse.topics.addAll(curr.topics);
                postUploading.value = false;
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
              if (curr is NewPostError) {
                postUploading.value = false;
                toast(
                  curr.message,
                  duration: Toast.LENGTH_LONG,
                );
              }
              if (curr is PostUpdateState) {
                List<PostViewModel>? feedRoomItemList =
                    widget.feedRoomPagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == curr.post.id) ??
                    -1;
                if (index != -1) {
                  feedRoomItemList?[index] = curr.post;
                }
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
            },
            builder: (context, state) {
              if (state is EditPostUploading) {
                return Container(
                  height: 60,
                  color: kWhiteColor,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 50,
                            height: 50,
                          ),
                          kHorizontalPaddingMedium,
                          Text('Saving')
                        ],
                      ),
                      CircularProgressIndicator(
                        backgroundColor: kGrey3Color,
                        valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                );
              }
              if (state is NewPostUploading) {
                return Container(
                  height: 60,
                  color: kWhiteColor,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          getLoaderThumbnail(state.thumbnailMedia),
                          kHorizontalPaddingMedium,
                          const Text('Posting')
                        ],
                      ),
                      StreamBuilder(
                          initialData: 0,
                          stream: state.progress,
                          builder: (context, snapshot) {
                            return SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  value: (snapshot.data == null ||
                                          snapshot.data == 0.0
                                      ? null
                                      : snapshot.data?.toDouble()),
                                  backgroundColor: kGrey3Color,
                                  valueColor: const AlwaysStoppedAnimation(
                                      kPrimaryColor),
                                  strokeWidth: 3,
                                ));
                          }),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: rebuildPostWidget,
                    builder: (context, _, __) {
                      return PagedListView<int, PostViewModel>(
                        pagingController: widget.feedRoomPagingController,
                        scrollController: _controller,
                        padding: EdgeInsets.zero,
                        builderDelegate:
                            PagedChildBuilderDelegate<PostViewModel>(
                          noItemsFoundIndicatorBuilder: (context) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const LMIcon(
                                  type: LMIconType.icon,
                                  icon: Icons.post_add,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                const Text("No posts to show",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    )),
                                const SizedBox(height: 12),
                                const Text("Be the first one to post here",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                        color: kGrey2Color)),
                                const SizedBox(height: 28),
                                LMTextButton(
                                  borderRadius: 28,
                                  height: 44,
                                  width: 153,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  text: LMTextView(
                                    text: "Create Post",
                                    textStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  placement: LMIconPlacement.end,
                                  icon: LMIcon(
                                    type: LMIconType.icon,
                                    icon: Icons.add,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  onTap: right
                                      ? () {
                                          if (!postUploading.value) {
                                            LMAnalytics.get().track(
                                                AnalyticsKeys
                                                    .postCreationStarted,
                                                {});
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const NewPostScreen(),
                                              ),
                                            );
                                          } else {
                                            toast(
                                              'A post is already uploading.',
                                              duration: Toast.LENGTH_LONG,
                                            );
                                          }
                                        }
                                      : () => toast(
                                          "You do not have permission to create a post"),
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (context, item, index) {
                            return Column(
                              children: [
                                const SizedBox(height: 8),
                                SSPostWidget(
                                  post: item,
                                  topics: widget.feedResponse.topics,
                                  user: widget.feedResponse.users[item.userId]!,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetailScreen(
                                            postId: item.id,
                                          ),
                                        ));
                                  },
                                  isFeed: true,
                                  refresh: (bool isDeleted) async {
                                    if (isDeleted) {
                                      List<PostViewModel>? feedRoomItemList =
                                          widget.feedRoomPagingController
                                              .itemList;
                                      feedRoomItemList?.removeAt(index);
                                      widget.feedRoomPagingController.itemList =
                                          feedRoomItemList;
                                      rebuildPostWidget.value =
                                          !rebuildPostWidget.value;
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: rebuildPostWidget,
        builder: (context, _, __) {
          return widget.feedRoomPagingController.itemList == null ||
                  widget.feedRoomPagingController.itemList!.isEmpty
              ? const SizedBox()
              : LMTextButton(
                  height: 44,
                  width: 153,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  borderRadius: 28,
                  backgroundColor: right
                      ? Theme.of(context).colorScheme.primary
                      : kGrey3Color,
                  placement: LMIconPlacement.end,
                  text: LMTextView(
                    text: "Create Post",
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  margin: 5,
                  icon: LMIcon(
                    type: LMIconType.icon,
                    icon: Icons.add,
                    fit: BoxFit.cover,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onTap: right
                      ? () {
                          if (!postUploading.value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewPostScreen(),
                              ),
                            );
                          } else {
                            toast(
                              'A post is already uploading.',
                              duration: Toast.LENGTH_LONG,
                            );
                          }
                        }
                      : () =>
                          toast("You do not have permission to create a post"),
                );
        },
      ),
    );
  }
}
