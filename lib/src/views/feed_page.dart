import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/universal_feed/universal_feed_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/views/new_post_screen.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/post_widget.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final UniversalFeedBloc _feedBloc;
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier postUploading = ValueNotifier(false);

  final PagingController<int, Post> _pagingController = PagingController(
    firstPageKey: 1,
  );

  @override
  void initState() {
    super.initState();
    // Bloc.observer = SimpleBlocObserver();
    _feedBloc = UniversalFeedBloc();
    _feedBloc.add(GetUniversalFeed(offset: _page, forLoadMore: false));
  }

  @override
  void dispose() {
    _feedBloc.close();
    _pagingController.dispose();
    super.dispose();
  }

  void _addPaginationListener() {
    _pagingController.addPageRequestListener((pageKey) {
      _feedBloc.add(GetUniversalFeed(offset: pageKey, forLoadMore: true));
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
      if (state.feed.posts.length < 10) {
        _pagingController.appendLastPage(state.feed.posts);
      } else {
        _pagingController.appendPage(state.feed.posts, _pageFeed);
      }
    }
  }

  // refresh() => () {
  //       setState(() {});
  //     };

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    _addPaginationListener();
    return Scaffold(
      backgroundColor: kWhiteColor.withOpacity(0.95),
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
        },
        child: BlocConsumer(
          bloc: _feedBloc,
          buildWhen: (prev, curr) {
            // Prevents changin the state while paginating the feed
            if (prev is UniversalFeedLoaded && curr is UniversalFeedLoading) {
              return false;
            }
            return true;
          },
          listener: (context, state) => updatePagingControllers(state),
          builder: ((context, state) {
            if (state is UniversalFeedLoaded) {
              GetFeedResponse feedResponse = state.feed;
              return PagedListView<int, Post>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Post>(
                  noItemsFoundIndicatorBuilder: (context) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LMIcon(
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
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: LMIcon(
                            icon: Icons.add,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          onTap: (active) {
                            if (!postUploading.value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BlocProvider<NewPostBloc>(
                                    create: (context) => NewPostBloc(),
                                    child: const NewPostScreen(),
                                  ),
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
                    Post rebuildPostData = item;
                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        SSPostWidget(
                          post: item,
                          user: feedResponse.users[item.userId]!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider<NewPostBloc>(
                                  create: (context) => NewPostBloc(),
                                  child: PostDetailScreen(
                                    postId: item.id,
                                  ),
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
                              item = updatedPostDetails.post!;
                              rebuildPostData = updatedPostDetails.post!;
                              List<Post>? feedRoomItemList =
                                  _pagingController.itemList;
                              feedRoomItemList?[index] =
                                  updatedPostDetails.post!;
                              _pagingController.itemList = feedRoomItemList;
                              rebuildPostWidget.value =
                                  !rebuildPostWidget.value;
                            } else {
                              List<Post>? feedRoomItemList =
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
            return const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      // floatingActionButton: ValueListenableBuilder(
      //   valueListenable: rebuildPostWidget,
      //   builder: (BuildContext context, dynamic value, Widget? child) {
      //     return  Container();
      //   },
      // ),,
      floatingActionButton: LMTextButton(
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
          icon: Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        onTap: (active) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider<NewPostBloc>(
                create: (context) => NewPostBloc(),
                child: const NewPostScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
