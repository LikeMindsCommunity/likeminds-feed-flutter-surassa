import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:likeminds_feed/likeminds_feed.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/simple_bloc_observer.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/universal_feed/universal_feed_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/utils.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/new_post_screen.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/post/post_something.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/post/post_widget.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class UniversalFeedScreen extends StatefulWidget {
  const UniversalFeedScreen({
    super.key,
  });

  @override
  State<UniversalFeedScreen> createState() => _UniversalFeedScreenState();
}

class _UniversalFeedScreenState extends State<UniversalFeedScreen> {
  late final UniversalFeedBloc _feedBloc; // bloc to fetch the feedroom data
  bool isCm = UserLocalPreference.instance
      .fetchMemberState(); // whether the logged in user is a community manager or not

  User user = UserLocalPreference.instance.fetchUserData();

  // future to get the unread notification count
  late Future<GetUnreadNotificationCountResponse> getUnreadNotificationCount;

  // used to rebuild the appbar
  final ValueNotifier _rebuildAppBar = ValueNotifier(false);

  // to control paging on FeedRoom View
  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _addPaginationListener();
    Bloc.observer = SimpleBlocObserver();
    _feedBloc = UniversalFeedBloc();
    _feedBloc.add(const GetUniversalFeed(offset: 1, forLoadMore: false));
    updateUnreadNotificationCount();
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

  int _pageFeed = 1; // current index of FeedRoom

  void _addPaginationListener() {
    _pagingController.addPageRequestListener((pageKey) {
      _feedBloc.add(GetUniversalFeed(offset: pageKey, forLoadMore: true));
    });
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(Object? state) {
    if (state is UniversalFeedLoaded) {
      _pageFeed++;
      if (state.feed.posts.length < 10) {
        _pagingController.appendLastPage(state.feed.posts);
      } else {
        _pagingController.appendPage(state.feed.posts, _pageFeed);
      }
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList!.clear();
    _pageFeed = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        centerTitle: false,
        title: const LMTextView(
          text: "Feed",
          textAlign: TextAlign.start,
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refresh();
          clearPagingController();
        },
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
  final PagingController<int, Post> feedRoomPagingController;
  final VoidCallback onRefresh;

  const FeedRoomView({
    super.key,
    required this.isCm,
    required this.feedResponse,
    required this.feedRoomPagingController,
    required this.user,
    required this.onRefresh,
  });

  @override
  State<FeedRoomView> createState() => _FeedRoomViewState();
}

class _FeedRoomViewState extends State<FeedRoomView> {
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier postUploading = ValueNotifier(false);
  ScrollController? _controller;
  final ValueNotifier postSomethingNotifier = ValueNotifier(false);

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
        // return SvgPicture.asset(
        //   kAssetDocPDFIcon,
        //   height: 35,
        //   width: 35,
        //   fit: BoxFit.cover,
        // );
        return const SizedBox();
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  var iconContainerHeight = 90.00;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller!.position.userScrollDirection == ScrollDirection.reverse) {
      if (iconContainerHeight != 0) {
        iconContainerHeight = 0;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
    if (_controller!.position.userScrollDirection == ScrollDirection.forward) {
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
                List<Post>? feedRoomItemList =
                    widget.feedRoomPagingController.itemList;
                feedRoomItemList!.removeWhere((item) => item.id == curr.postId);
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
                Post? item = curr.postData;
                int length =
                    widget.feedRoomPagingController.itemList?.length ?? 0;
                List<Post> feedRoomItemList =
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
                widget.feedRoomPagingController.itemList = feedRoomItemList;
                postUploading.value = false;
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
              if (curr is EditPostUploaded) {
                Post? item = curr.postData;
                List<Post>? feedRoomItemList =
                    widget.feedRoomPagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == item.id) ??
                    -1;
                if (index != -1) {
                  feedRoomItemList?[index] = item;
                }
                widget.feedResponse.users.addAll(curr.userData);
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
                List<Post>? feedRoomItemList =
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
                                      : snapshot.data!.toDouble()),
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
                ValueListenableBuilder(
                    valueListenable: postSomethingNotifier,
                    builder: (context, _, __) {
                      return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: iconContainerHeight,
                          child: const PostSomething());
                    }),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: rebuildPostWidget,
                    builder: (context, _, __) {
                      return PagedListView<int, Post>(
                        pagingController: widget.feedRoomPagingController,
                        scrollController: _controller,
                        padding: EdgeInsets.zero,
                        builderDelegate: PagedChildBuilderDelegate<Post>(
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
                                  height: 48,
                                  width: 142,
                                  borderRadius: 28,
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
                                  icon: LMIcon(
                                    type: LMIconType.icon,
                                    icon: Icons.add,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  onTap: () {
                                    if (!postUploading.value) {
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
                                  },
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
                                    if (!isDeleted) {
                                      final GetPostResponse updatedPostDetails =
                                          await locator<LikeMindsService>()
                                              .getPost(
                                        (GetPostRequestBuilder()
                                              ..postId(item.id)
                                              ..page(1)
                                              ..pageSize(10))
                                            .build(),
                                      );
                                      item = updatedPostDetails.post!;
                                      List<Post>? feedRoomItemList = widget
                                          .feedRoomPagingController.itemList;
                                      feedRoomItemList?[index] =
                                          updatedPostDetails.post!;
                                      widget.feedRoomPagingController.itemList =
                                          feedRoomItemList;
                                      rebuildPostWidget.value =
                                          !rebuildPostWidget.value;
                                    } else {
                                      List<Post>? feedRoomItemList = widget
                                          .feedRoomPagingController.itemList;
                                      feedRoomItemList!.removeAt(index);
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
                  height: 48,
                  width: 142,
                  borderRadius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  text: LMTextView(
                    text: "Create Post",
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: LMIcon(
                    type: LMIconType.icon,
                    icon: Icons.add,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewPostScreen(),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
