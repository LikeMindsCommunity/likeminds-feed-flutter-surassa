import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/topic/bloc/topic_bloc.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class TopicBottomSheet extends StatefulWidget {
  final List<TopicViewModel> selectedTopics;
  final Function(List<TopicViewModel>, TopicViewModel) onTopicSelected;
  final bool? isEnabled;
  const TopicBottomSheet({
    Key? key,
    required this.selectedTopics,
    required this.onTopicSelected,
    this.isEnabled,
  }) : super(key: key);

  @override
  State<TopicBottomSheet> createState() => _TopicBottomSheetState();
}

class _TopicBottomSheetState extends State<TopicBottomSheet> {
  List<TopicViewModel> selectedTopics = [];
  bool paginationComplete = false;
  ScrollController controller = ScrollController();
  FocusNode keyboardNode = FocusNode();
  Set<String> selectedTopicId = {};
  TextEditingController searchController = TextEditingController();
  String searchType = "";
  String search = "";
  TopicViewModel allTopics = TopicViewModel(
    name: "All Topics",
    id: "0",
    isEnabled: true,
  );
  final int pageSize = 100;
  TopicBloc topicBloc = TopicBloc();
  bool isSearching = false;
  ValueNotifier<bool> rebuildTopicsScreen = ValueNotifier<bool>(false);
  PagingController<int, TopicViewModel> topicsPagingController =
      PagingController(firstPageKey: 1);

  int _page = 1;

  bool checkSelectedTopicExistsInList(TopicViewModel topic) {
    return selectedTopicId.contains(topic.id);
  }

  @override
  void initState() {
    super.initState();
    selectedTopics = widget.selectedTopics;
    for (TopicViewModel topic in selectedTopics) {
      selectedTopicId.add(topic.id);
    }
    topicsPagingController.itemList = selectedTopics;
    topicBloc.add(
      GetTopic(
        getTopicFeedRequest: (GetTopicsRequestBuilder()
              ..page(_page)
              ..isEnabled(widget.isEnabled)
              ..pageSize(pageSize)
              ..search(search)
              ..searchType(searchType))
            .build(),
      ),
    );
    _addPaginationListener();
  }

  @override
  void dispose() {
    searchController.dispose();
    topicBloc.close();
    keyboardNode.dispose();
    super.dispose();
  }

  _addPaginationListener() {
    controller.addListener(() {
      if (controller.position.atEdge) {
        bool isTop = controller.position.pixels == 0;
        if (!isTop) {
          topicBloc.add(GetTopic(
            getTopicFeedRequest: (GetTopicsRequestBuilder()
                  ..page(_page)
                  ..isEnabled(widget.isEnabled)
                  ..pageSize(pageSize)
                  ..search(search)
                  ..searchType(searchType))
                .build(),
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    return Container(
      width: screenSize.width,
      height: 500,
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: BlocConsumer<TopicBloc, TopicState>(
        bloc: topicBloc,
        buildWhen: (previous, current) {
          if (current is TopicLoading && _page != 1) {
            return false;
          }
          return true;
        },
        listener: (context, state) {
          if (state is TopicLoaded) {
            _page++;
            if (state.getTopicFeedResponse.topics!.isEmpty) {
              topicsPagingController.appendLastPage([]);
            } else {
              state.getTopicFeedResponse.topics?.removeWhere(
                  (element) => selectedTopicId.contains(element.id));
              topicsPagingController.appendPage(
                state.getTopicFeedResponse.topics!
                    .map((e) => TopicViewModel.fromTopic(e))
                    .toList(),
                _page,
              );
            }
          } else if (state is TopicError) {
            topicsPagingController.error = state.errorMessage;
          }
        },
        builder: (context, state) {
          if (state is TopicLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TopicLoaded) {
            return ValueListenableBuilder(
                valueListenable: rebuildTopicsScreen,
                builder: (context, _, __) {
                  return Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: LMTextView(
                          text: 'Topics',
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                          child: SingleChildScrollView(
                        controller: controller,
                        child: Wrap(
                          children: topicsPagingController.itemList?.map((e) {
                                bool isTopicSelected =
                                    selectedTopicId.contains(e.id);
                                return GestureDetector(
                                  onTap: () {
                                    if (isTopicSelected) {
                                      selectedTopicId.remove(e.id);
                                      selectedTopics.removeWhere(
                                          (element) => element.id == e.id);
                                    } else {
                                      selectedTopicId.add(e.id);
                                      selectedTopics.add(e);
                                    }
                                    isTopicSelected = !isTopicSelected;
                                    rebuildTopicsScreen.value =
                                        !rebuildTopicsScreen.value;
                                    widget.onTopicSelected(selectedTopics, e);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 8.0, bottom: 8.0),
                                    child: Chip(
                                      label: LMTextView(
                                        text: e.name,
                                        textStyle: TextStyle(
                                          color: isTopicSelected
                                              ? Colors.white
                                              : appBlack,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 1.30,
                                        ),
                                      ),
                                      backgroundColor: isTopicSelected
                                          ? theme.colorScheme.secondary
                                          : kWhiteColor,
                                      onDeleted: null,
                                      clipBehavior: Clip.hardEdge,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                          side: isTopicSelected
                                              ? BorderSide.none
                                              : const BorderSide(
                                                  color: appSecondaryBlack,
                                                  width: 1.0,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(21.0)),
                                    ),
                                  ),
                                );
                              }).toList() ??
                              [],
                        ),
                      )
                          // child: PagedListView(
                          //   pagingController: topicsPagingController,
                          //   padding: EdgeInsets.zero,
                          //   physics: const ClampingScrollPhysics(),
                          //   builderDelegate:
                          //       PagedChildBuilderDelegate<TopicViewModel>(
                          //     noItemsFoundIndicatorBuilder: (context) =>
                          //         const Center(
                          //             child: Text(
                          //       "Opps, no topics found!",
                          //     )),

                          //     itemBuilder: (context, item, index) => TopicTile(
                          //       isSelected: checkSelectedTopicExistsInList(item),
                          //       topic: item,
                          //       height: 50,
                          //       text: LMTextView(
                          //         text: item.name,
                          //         textStyle: const TextStyle(
                          //           color: kGrey1Color,
                          //           fontWeight: FontWeight.w600,
                          //         ),
                          //       ),
                          //       backgroundColor: kWhiteColor,
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 20.0, vertical: 16.0),
                          //       icon: const Icon(
                          //         Icons.check_circle,
                          //         color: kPrimaryColor,
                          //       ),
                          //       onTap: (TopicViewModel tappedTopic) {
                          //         int index = selectedTopics.indexWhere(
                          //             (element) => element.id == tappedTopic.id);
                          //         if (index != -1) {
                          //           selectedTopics.removeAt(index);
                          //           selectedTopicId.remove(tappedTopic.id);
                          //         } else {
                          //           selectedTopics.add(tappedTopic);
                          //           selectedTopicId.add(tappedTopic.id);
                          //         }
                          //         rebuildTopicsScreen.value =
                          //             !rebuildTopicsScreen.value;
                          //       },
                          //     ),
                          //   ),
                          // ),

                          ),
                    ],
                  );
                });
          } else if (state is TopicError) {
            return Center(
              child: Text(state.errorMessage),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
