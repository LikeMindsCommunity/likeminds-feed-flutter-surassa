import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/universal_feed/universal_feed_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/models/post_view_model.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/new_post_screen.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/post/post_widget.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool showScrollButton = true;
  ScrollController scrollController = ScrollController();
  late final UniversalFeedBloc _feedBloc;
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier postUploading = ValueNotifier(false);

  final PagingController<int, PostViewModel> _pagingController =
      PagingController(
    firstPageKey: 1,
  );

  void _scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    // Bloc.observer = SimpleBlocObserver();
    _feedBloc = UniversalFeedBloc();
    _feedBloc.add(const GetUniversalFeed(offset: 1));
    scrollController.addListener(() {
      _showScrollToBottomButton();
    });
    _addPaginationListener();
  }

  void _showScrollToBottomButton() {
    if (scrollController.offset > 10.0) {
      _showButton();
    } else {
      _hideButton();
    }
  }

  void _showButton() {
    setState(() {
      showScrollButton = true;
    });
  }

  void _hideButton() {
    setState(() {
      showScrollButton = false;
    });
  }

  @override
  void dispose() {
    _feedBloc.close();
    scrollController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  void _addPaginationListener() {
    _pagingController.addPageRequestListener((pageKey) {
      _feedBloc.add(GetUniversalFeed(offset: pageKey));
    });
  }

  void refresh() => _pagingController.refresh();

  int _pageFeed = 1; // current index of FeedRoom

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList!.clear();
    _pageFeed = 1;
  }

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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = LMThemeData.suraasaTheme;
    return Scaffold(
      backgroundColor: LMThemeData.kWhiteColor.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: LMThemeData.kWhiteColor,
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
              GetFeedResponse feedResponse = state.feed;
              return PagedListView<int, PostViewModel>(
                pagingController: _pagingController,
                scrollController: scrollController,
                builderDelegate: PagedChildBuilderDelegate<PostViewModel>(
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
                                color: LMThemeData.kGrey2Color)),
                        const SizedBox(height: 28),
                        LMTextButton(
                          height: 48,
                          width: 142,
                          borderRadius: 28,
                          backgroundColor:
                             theme.colorScheme.primary,
                          text: LMTextView(
                            text: "Create Post",
                            textStyle: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: LMIcon(
                            type: LMIconType.icon,
                            icon: Icons.add,
                            color: theme.colorScheme.onPrimary,
                          ),
                          onTap: () {
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
                          user: feedResponse.users[item.userId]!,
                          topics: feedResponse.topics,
                          onTap: () {
                            LMAnalytics.get()
                                .track(AnalyticsKeys.commentListOpen, {
                              'postId': item.id,
                            });
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
                            if (!isDeleted) {
                              final GetPostResponse updatedPostDetails =
                                  await locator<LikeMindsService>().getPost(
                                (GetPostRequestBuilder()
                                      ..postId(item.id)
                                      ..page(1)
                                      ..pageSize(10))
                                    .build(),
                              );
                              item = PostViewModel.fromPost(
                                  post: updatedPostDetails.post!);
                              List<PostViewModel>? feedRoomItemList =
                                  _pagingController.itemList;
                              feedRoomItemList?[index] = item;
                              _pagingController.itemList = feedRoomItemList;
                              rebuildPostWidget.value =
                                  !rebuildPostWidget.value;
                            } else {
                              List<PostViewModel>? feedRoomItemList =
                                  _pagingController.itemList;
                              feedRoomItemList!.removeAt(index);
                              _pagingController.itemList = feedRoomItemList;
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
            }
            return const Center(
                child: LMLoader(
              color: LMThemeData.kPrimaryColor,
            ));
          }),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        children: [
          Container(
            height: 25,
            margin: const EdgeInsets.only(bottom: 12),
            width: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LMThemeData.kPrimaryColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 25,
                  color: Colors.black.withOpacity(0.3),
                )
              ],
            ),
            child: Center(
              child: LMIconButton(
                onTap: (value) {
                  _scrollToTop();
                },
                icon: const LMIcon(
                  type: LMIconType.icon,
                  icon: Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
          LMTextButton(
            height: 48,
            width: 142,
            borderRadius: 28,
            backgroundColor: theme.colorScheme.primary,
            text: LMTextView(
              text: "Create Post",
              textStyle: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: LMIcon(
              type: LMIconType.icon,
              icon: Icons.add,
              size: 12,
              color: theme.colorScheme.onPrimary,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewPostScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
