import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:likeminds_feed/likeminds_feed.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/post_bloc/post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/simple_bloc_observer.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/universal_feed/universal_feed_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
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
  final ScrollController _controller = ScrollController();

  // notifies value listenable builder to rebuild the topic feed
  ValueNotifier<bool> rebuildTopicFeed = ValueNotifier(false);

  // future to get the topics
  Future<GetTopicsResponse>? getTopicsResponse;

  // list of selected topics by the user
  List<TopicUI> selectedTopics = [];
  bool topicVisible = true;

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
  final PagingController<int, PostViewData> _pagingController =
      PagingController(firstPageKey: 1);

  final ValueNotifier postSomethingNotifier = ValueNotifier(false);
  bool userPostingRights = true;
  var iconContainerHeight = 60.00;

  @override
  void initState() {
    super.initState();
    _addPaginationListener();
    getTopicsResponse = locator<LMFeedClient>().getTopics(
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
    if (!memberStateResponse.success || memberStateResponse.state == 1) {
      return true;
    }
    final memberRights = UserLocalPreference.instance.fetchMemberRight(9);
    return memberRights;
  }

  void _scrollListener() {
    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (iconContainerHeight != 0) {
        iconContainerHeight = 0;
        topicVisible = false;
        rebuildTopicFeed.value = !rebuildTopicFeed.value;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
    if (_controller.position.userScrollDirection == ScrollDirection.forward) {
      if (iconContainerHeight == 0) {
        iconContainerHeight = 60.0;
        topicVisible = true;
        rebuildTopicFeed.value = !rebuildTopicFeed.value;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
  }

  void updateSelectedTopics(List<TopicUI> topics) {
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
        locator<LMFeedClient>().getUnreadNotificationCount();
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
      List<PostViewData> listOfPosts =
          state.feed.posts.map((e) => PostViewData.fromPost(post: e)).toList();
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

  void showTopicSelectSheet() {
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isDismissible: true,
      useRootNavigator: true,
      backgroundColor: LMThemeData.kWhiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.0),
          topRight: Radius.circular(28.0),
        ),
      ),
      enableDrag: false,
      clipBehavior: Clip.hardEdge,
      builder: (context) => TopicBottomSheet(
        key: GlobalKey(),
        selectedTopics: selectedTopics,
        onTopicSelected: (updatedTopics, tappedTopic) {
          updateSelectedTopics(updatedTopics);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = LMThemeData.suraasaTheme;
    return Scaffold(
      backgroundColor: LMThemeData.kWhiteColor,
      appBar: AppBar(
        backgroundColor: LMThemeData.kWhiteColor,
        centerTitle: false,
        title: GestureDetector(
          onTap: () {
            _scrollToTop();
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: LMTextView(
              text: "Feed",
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
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
            LMThemeData.kVerticalPaddingLarge,
            ValueListenableBuilder(
              valueListenable: postSomethingNotifier,
              builder: (context, _, __) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: iconContainerHeight,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: PostSomething(
                    enabled: userPostingRights,
                  ),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: rebuildTopicFeed,
              builder: (context, _, __) {
                return Visibility(
                  visible: topicVisible,
                  maintainAnimation: true,
                  maintainState: true,
                  child: FutureBuilder<GetTopicsResponse>(
                      future: getTopicsResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.success == true) {
                          if (snapshot.data!.topics!.isNotEmpty) {
                            return Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 12.0),
                              child: GestureDetector(
                                onTap: () => showTopicSelectSheet(),
                                child: Row(
                                  children: [
                                    selectedTopics.isEmpty
                                        ? LMTopicChip(
                                            topic: (TopicUIBuilder()
                                                  ..id("0")
                                                  ..isEnabled(true)
                                                  ..name("Topic"))
                                                .build(),
                                            borderRadius: 20.0,
                                            borderWidth: 1,
                                            showBorder: true,
                                            borderColor:
                                                LMThemeData.appSecondaryBlack,
                                            textStyle: const TextStyle(
                                              color: LMThemeData.appBlack,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 4.0),
                                            icon: const LMIcon(
                                              type: LMIconType.icon,
                                              icon: CupertinoIcons.chevron_down,
                                              size: 16,
                                              color: LMThemeData.appBlack,
                                            ),
                                          )
                                        : selectedTopics.length == 1
                                            ? LMTopicChip(
                                                topic: (TopicUIBuilder()
                                                      ..id(selectedTopics
                                                          .first.id)
                                                      ..isEnabled(selectedTopics
                                                          .first.isEnabled)
                                                      ..name(selectedTopics
                                                          .first.name))
                                                    .build(),
                                                borderRadius: 20.0,
                                                showBorder: false,
                                                backgroundColor:
                                                    theme.colorScheme.secondary,
                                                textStyle: const TextStyle(
                                                  color:
                                                      LMThemeData.kWhiteColor,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 4.0),
                                                icon: const LMIcon(
                                                  type: LMIconType.icon,
                                                  icon: CupertinoIcons
                                                      .chevron_down,
                                                  size: 16,
                                                  color:
                                                      LMThemeData.kWhiteColor,
                                                ),
                                              )
                                            : LMTopicChip(
                                                topic: (TopicUIBuilder()
                                                      ..id("0")
                                                      ..isEnabled(true)
                                                      ..name("Topics"))
                                                    .build(),
                                                borderRadius: 20.0,
                                                showBorder: false,
                                                backgroundColor:
                                                    theme.colorScheme.secondary,
                                                textStyle: const TextStyle(
                                                  color:
                                                      LMThemeData.kWhiteColor,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 4.0),
                                                icon: Row(
                                                  children: [
                                                    LMThemeData
                                                        .kHorizontalPaddingXSmall,
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4)),
                                                      ),
                                                      child: LMTextView(
                                                        text: selectedTopics
                                                            .length
                                                            .toString(),
                                                        textStyle:
                                                            const TextStyle(
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
                                                    LMThemeData
                                                        .kHorizontalPaddingSmall,
                                                    const LMIcon(
                                                      type: LMIconType.icon,
                                                      icon: CupertinoIcons
                                                          .chevron_down,
                                                      size: 16,
                                                      color: LMThemeData
                                                          .kWhiteColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                        return const SizedBox();
                      }),
                );
              },
            ),
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
                      universalFeedBloc: _feedBloc,
                      feedResponse: state.feed,
                      feedRoomPagingController: _pagingController,
                      user: user,
                      onRefresh: refresh,
                      scrollController: _controller,
                      openTopicBottomSheet: showTopicSelectSheet,
                    );
                  } else if (state is UniversalFeedError) {
                    return FeedRoomErrorView(message: state.message);
                  }
                  return const Scaffold(
                    backgroundColor: LMThemeData.kBackgroundColor,
                    body: Center(
                      child: LMLoader(
                        color: LMThemeData.kPrimaryColor,
                      ),
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
        backgroundColor: LMThemeData.kBackgroundColor,
        body: Center(child: Text(message)));
  }
}

class FeedRoomView extends StatefulWidget {
  final bool isCm;
  final User user;
  final UniversalFeedBloc universalFeedBloc;
  final GetFeedResponse feedResponse;
  final PagingController<int, PostViewData> feedRoomPagingController;
  final ScrollController scrollController;
  final VoidCallback onRefresh;
  final VoidCallback openTopicBottomSheet;

  const FeedRoomView({
    super.key,
    required this.isCm,
    required this.universalFeedBloc,
    required this.feedResponse,
    required this.feedRoomPagingController,
    required this.user,
    required this.onRefresh,
    required this.scrollController,
    required this.openTopicBottomSheet,
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
        return Container(
          height: 50,
          width: 50,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: LMImage(
            imageFile: media.mediaFile!,
            boxFit: BoxFit.contain,
          ),
        );
      } else if (media.mediaType == MediaType.document) {
        return const LMIcon(
          type: LMIconType.svg,
          assetPath: kAssetDocPDFIcon,
          color: Colors.red,
          size: 35,
          boxPadding: 0,
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
    if (!memberStateResponse.success || memberStateResponse.state == 1) {
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
    locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
        eventName: AnalyticsKeys.feedOpened,
        eventProperties: const {'feed_type': "universal_feed"}));
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
    LMPostBloc newPostBloc = locator<LMFeedBloc>().lmPostBloc;
    final ThemeData theme = LMThemeData.suraasaTheme;
    return Scaffold(
      backgroundColor: LMThemeData.kBackgroundColor,
      body: Column(
        children: [
          BlocConsumer<LMPostBloc, LMPostState>(
            bloc: newPostBloc,
            listener: (prev, curr) {
              if (curr is PostDeleted) {
                List<PostViewData>? feedRoomItemList =
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
                PostViewData? item = curr.postData;
                int length =
                    widget.feedRoomPagingController.itemList?.length ?? 0;
                List<PostViewData> feedRoomItemList =
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
                widget.feedResponse.topics.addAll(curr.topics
                    .map((key, value) => MapEntry(key, value.toTopic())));
                widget.feedRoomPagingController.itemList = feedRoomItemList;
                postUploading.value = false;
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
              if (curr is EditPostUploaded) {
                PostViewData? item = curr.postData;
                List<PostViewData>? feedRoomItemList =
                    widget.feedRoomPagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == item.id) ??
                    -1;
                if (index != -1) {
                  feedRoomItemList?[index] = item;
                }
                widget.feedResponse.users.addAll(curr.userData);
                widget.feedResponse.topics.addAll(curr.topics
                    .map((key, value) => MapEntry(key, value.toTopic())));
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
                List<PostViewData>? feedRoomItemList =
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
                  color: LMThemeData.kWhiteColor,
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
                          LMThemeData.kHorizontalPaddingMedium,
                          Text('Saving')
                        ],
                      ),
                      CircularProgressIndicator(
                        backgroundColor: LMThemeData.kGrey3Color,
                        valueColor:
                            AlwaysStoppedAnimation(LMThemeData.kPrimaryColor),
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                );
              }
              if (state is NewPostUploading) {
                return Container(
                  height: 60,
                  color: LMThemeData.kWhiteColor,
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
                          LMThemeData.kHorizontalPaddingMedium,
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
                                  backgroundColor: LMThemeData.kGrey3Color,
                                  valueColor: const AlwaysStoppedAnimation(
                                      LMThemeData.kPrimaryColor),
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
                      return PagedListView<int, PostViewData>(
                        pagingController: widget.feedRoomPagingController,
                        scrollController: _controller,
                        padding: EdgeInsets.zero,
                        builderDelegate:
                            PagedChildBuilderDelegate<PostViewData>(
                          noItemsFoundIndicatorBuilder: (context) {
                            if (widget.universalFeedBloc.state
                                    is UniversalFeedLoaded &&
                                (widget.universalFeedBloc.state
                                        as UniversalFeedLoaded)
                                    .topics
                                    .isNotEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const LMTextView(
                                      text:
                                          "Looks like there are no posts for this topic yet.",
                                      textStyle: TextStyle(
                                        fontSize: 15,
                                        color: LMThemeData.onSurface500,
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        LMTextButton(
                                          borderRadius: 48,
                                          height: 40,
                                          border: Border.all(
                                            color: LMThemeData.primary500,
                                            width: 2,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          text: const LMTextView(
                                            text: "Change Filter",
                                            textAlign: TextAlign.center,
                                            textStyle: TextStyle(
                                              color: LMThemeData.primary500,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          onTap: () =>
                                              widget.openTopicBottomSheet(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const LMIcon(
                                    type: LMIconType.icon,
                                    icon: Icons.post_add,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  const LMTextView(
                                    text: 'No posts to show',
                                    textStyle: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const LMTextView(
                                      text: "Be the first one to post here",
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                          color: LMThemeData.kGrey2Color)),
                                  const SizedBox(height: 28),
                                  LMTextButton(
                                    borderRadius: 28,
                                    height: 44,
                                    width: 153,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    backgroundColor: theme.colorScheme.primary,
                                    text: LMTextView(
                                      text: "Create Post",
                                      textStyle: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    placement: LMIconPlacement.end,
                                    icon: LMIcon(
                                      type: LMIconType.icon,
                                      icon: Icons.add,
                                      size: 18,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                    onTap: right
                                        ? () {
                                            if (!postUploading.value) {
                                              LMAnalytics.get().track(
                                                  AnalyticsKeys
                                                      .postCreationStarted,
                                                  {});
                                              locator<LMFeedBloc>()
                                                  .lmAnalyticsBloc
                                                  .add(FireAnalyticEvent(
                                                      eventName: AnalyticsKeys
                                                          .postCreationStarted,
                                                      eventProperties: const {}));

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
                            );
                          },
                          itemBuilder: (context, item, index) {
                            if (widget.feedResponse.users[item.userId] ==
                                null) {
                              return const SizedBox();
                            }
                            return Column(
                              children: [
                                const SizedBox(height: 8),
                                SSPostWidget(
                                  post: item,
                                  topics: widget.feedResponse.topics,
                                  user: widget.feedResponse.users[item.userId]!,
                                  onTap: () {
                                    LMAnalytics.get()
                                        .track(AnalyticsKeys.commentListOpen, {
                                      'postId': item.id,
                                    });
                                    locator<LMFeedBloc>()
                                        .lmAnalyticsBloc
                                        .add(FireAnalyticEvent(
                                            eventName:
                                                AnalyticsKeys.commentListOpen,
                                            eventProperties: {
                                              'postId': item.id,
                                            }));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PostDetailScreen(
                                          postId: item.id,
                                        ),
                                      ),
                                    );
                                  },
                                  isFeed: true,
                                  refresh: (bool isDeleted) async {
                                    if (isDeleted) {
                                      List<PostViewData>? feedRoomItemList =
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
                      ? theme.colorScheme.primary
                      : LMThemeData.kGrey3Color,
                  placement: LMIconPlacement.end,
                  text: LMTextView(
                    text: "Create Post",
                    textStyle: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  margin: 5,
                  icon: LMIcon(
                    type: LMIconType.icon,
                    icon: Icons.add,
                    fit: BoxFit.cover,
                    size: 18,
                    color: theme.colorScheme.onPrimary,
                  ),
                  onTap: right
                      ? () {
                          if (!postUploading.value) {
                            LMAnalytics.get()
                                .track(AnalyticsKeys.postCreationStarted, {});
                            locator<LMFeedBloc>().lmAnalyticsBloc.add(
                                FireAnalyticEvent(
                                    eventName:
                                        AnalyticsKeys.postCreationStarted,
                                    eventProperties: const {}));
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
