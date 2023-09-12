import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/topic/bloc/topic_bloc.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class TopicPopUp extends StatefulWidget {
  final List<TopicViewModel> selectedTopics;
  final Function(List<TopicViewModel>, TopicViewModel) onTopicSelected;
  final bool? isEnabled;
  const TopicPopUp({
    Key? key,
    required this.selectedTopics,
    required this.onTopicSelected,
    this.isEnabled,
  }) : super(key: key);

  @override
  State<TopicPopUp> createState() => _TopicPopUpState();
}

class _TopicPopUpState extends State<TopicPopUp> {
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
    selectedTopics = [...widget.selectedTopics];
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
    controller.addListener(
      () {
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    return Container(
      width: min(screenSize.width, 254),
      height: 216,
      decoration: BoxDecoration(
          color: kWhiteColor, borderRadius: BorderRadius.circular(4.0)),
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(8.0),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: controller,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      width: double.infinity,
                                      color: isTopicSelected
                                          ? kSecondaryColorLight
                                          : kWhiteColor,
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.only(
                                          right: 8.0, bottom: 8.0),
                                      child: Chip(
                                        label: LMTextView(
                                          text: e.name,
                                          textStyle: TextStyle(
                                            color: isTopicSelected
                                                ? theme.colorScheme.secondary
                                                : appBlack,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            height: 1.30,
                                          ),
                                        ),
                                        backgroundColor: isTopicSelected
                                            ? kSecondaryColorLight
                                            : kWhiteColor,
                                        onDeleted: null,
                                        clipBehavior: Clip.hardEdge,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0)),
                                      ),
                                    ),
                                  );
                                }).toList() ??
                                [],
                          ),
                        ),
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
