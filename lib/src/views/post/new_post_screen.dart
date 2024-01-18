import 'dart:async';
import 'dart:io';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';
import 'package:likeminds_feed_ss_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/local_preference/user_local_preference.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_media_picker.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_utils.dart';
import 'package:likeminds_feed_ss_fl/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/post_composer_header.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/topic/topic_popup.dart';

import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:open_filex/open_filex.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

class NewPostScreen extends StatefulWidget {
  final String? populatePostText;
  final List<AttachmentPostViewData>? populatePostMedia;

  const NewPostScreen({
    super.key,
    this.populatePostText,
    this.populatePostMedia,
  });

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Future<GetTopicsResponse>? getTopicsResponse;
  ValueNotifier<bool> rebuildLinkPreview = ValueNotifier(false);
  List<TopicUI> selectedTopic = [];
  ValueNotifier<bool> rebuildTopicFloatingButton = ValueNotifier(false);
  final CustomPopupMenuController _controllerPopUp =
      CustomPopupMenuController();
  VideoController? videoController;

  LMPostBloc? lmPostBloc;
  late final User user;

  List<AttachmentPostViewData> postMedia = [];
  List<UserTag> userTags = [];
  String? result;

  bool isDocumentPost = true; // flag for document or media post
  bool isMediaPost = true;
  bool isVideoAttached = false;
  bool isUploading = false;

  String previewLink = '';
  AttachmentPostViewData? linkModel;
  bool showLinkPreview =
      true; // if set to false link preview should not be displayed
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    user = UserLocalPreference.instance.fetchUserData();
    getTopicsResponse =
        locator<LMFeedClient>().getTopics((GetTopicsRequestBuilder()
              ..page(1)
              ..pageSize(20)
              ..isEnabled(true))
            .build());
    lmPostBloc = locator<LMFeedBloc>().lmPostBloc;
    if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }
  }

  /*
  * Removes the media from the list
  * whenever the user taps on the X button
  */
  void removeAttachmenetAtIndex(int index) {
    if (postMedia.isNotEmpty) {
      AttachmentPostViewData mediaToBeRemoved = postMedia[index];
      if (mediaToBeRemoved.mediaType == MediaType.document) {
        int docCount = 0;
        for (var element in postMedia) {
          if (element.mediaType == MediaType.document) {
            docCount++;
          }
        }
        LMAnalytics.get().track(
            AnalyticsKeys.documentAttachedInPost, {'document_count': docCount});
        locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
              eventName: AnalyticsKeys.documentAttachedInPost,
              eventProperties: {'document_count': docCount},
            ));
      } else if (mediaToBeRemoved.mediaType == MediaType.video) {
        int videoCount = 0;
        for (var element in postMedia) {
          if (element.mediaType == MediaType.video) {
            videoCount++;
          }
        }
        LMAnalytics.get().track(
            AnalyticsKeys.videoAttachedToPost, {'video_count': videoCount});
        locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
            eventName: AnalyticsKeys.videoAttachedToPost,
            eventProperties: {'video_count': videoCount}));
      } else if (mediaToBeRemoved.mediaType == MediaType.image) {
        int imageCount = 0;
        for (var element in postMedia) {
          if (element.mediaType == MediaType.image) {
            imageCount++;
          }
        }
        LMAnalytics.get().track(
            AnalyticsKeys.imageAttachedToPost, {'image_count': imageCount});
        locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
            eventName: AnalyticsKeys.imageAttachedToPost,
            eventProperties: {'image_count': imageCount}));
      }

      postMedia.removeAt(index);
      if (postMedia.isEmpty) {
        isDocumentPost = true;
        isMediaPost = true;
        showLinkPreview = true;
        isVideoAttached = false;
      }
      setState(() {});
    }
  }

  // this function initiliases postMedia list
  // with photos/videos picked by the user
  void setPickedMediaFiles(List<AttachmentPostViewData> pickedMediaFiles) {
    if (postMedia.isEmpty) {
      postMedia = <AttachmentPostViewData>[...pickedMediaFiles];
    } else {
      postMedia.addAll(pickedMediaFiles);
    }
    if (pickedMediaFiles.isNotEmpty &&
        pickedMediaFiles.first.mediaType == MediaType.document) {
      int documentCount = 0;
      for (var element in postMedia) {
        if (element.mediaType == MediaType.document) {
          documentCount++;
        }
      }
      LMAnalytics.get().track(AnalyticsKeys.documentAttachedInPost,
          {'document_count': documentCount});
      locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
            eventName: AnalyticsKeys.documentAttachedInPost,
            eventProperties: {'document_count': documentCount},
          ));
    } else {
      if (postMedia.first.mediaType == MediaType.video) {
        LMAnalytics.get()
            .track(AnalyticsKeys.videoAttachedToPost, {'video_count': 1});
        locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
            eventName: AnalyticsKeys.videoAttachedToPost,
            eventProperties: const {'video_count': 1}));
        isVideoAttached = true;
      } else {
        int imageCount = 0;
        for (var element in postMedia) {
          if (element.mediaType == MediaType.image) {
            imageCount++;
          }
        }
        LMAnalytics.get().track(
            AnalyticsKeys.imageAttachedToPost, {'image_count': imageCount});
        locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
            eventName: AnalyticsKeys.imageAttachedToPost,
            eventProperties: {'image_count': imageCount}));
      }
    }
  }

  /*
  * Changes state to uploading
  * for showing a circular loader while the user is
  * picking files
  */
  void onUploading() {
    setState(() {
      isUploading = true;
    });
  }

  /*
  * Changes state to uploaded
  * for showing the picked files
  */
  void onUploadedMedia(bool uploadResponse) {
    if (uploadResponse) {
      isMediaPost = true;
      showLinkPreview = false;
      isDocumentPost = false;
      setState(() {
        isUploading = false;
      });
    } else {
      if (postMedia.isEmpty) {
        isMediaPost = true;
        isVideoAttached = false;
        showLinkPreview = true;
      }
      setState(() {
        isUploading = false;
      });
    }
  }

  void onUploadedDocument(bool uploadResponse) {
    if (uploadResponse) {
      isDocumentPost = true;
      showLinkPreview = false;
      isMediaPost = false;
      setState(() {
        isUploading = false;
      });
    } else {
      if (postMedia.isEmpty) {
        isDocumentPost = true;
        isMediaPost = true;
        isVideoAttached = false;
        showLinkPreview = true;
      }
      setState(() {
        isUploading = false;
      });
    }
  }

  /*
  * This function return a list
  * containing LMDocument widget
  * which generates preview for a document
  */
  Widget getPostDocument(double width) {
    return ListView.builder(
      itemCount: postMedia.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => LMDocument(
        size: getFileSizeString(bytes: postMedia[index].size!),
        onTap: () {
          OpenFilex.open(postMedia[index].mediaFile!.path);
        },
        type: postMedia[index].format!,
        documentIcon: const LMIcon(
          type: LMIconType.svg,
          assetPath: kAssetDocPDFIcon,
          color: Colors.red,
          size: 45,
          boxPadding: 0,
        ),
        backgroundColor: LMThemeData.kSecondary100,
        documentFile: postMedia[index].mediaFile,
        onRemove: () => removeAttachmenetAtIndex(index),
      ),
    );
  }

  /*
  * Takes a string as input
  * extracts the first valid link from the string
  * decodes the url using LikeMinds SDK
  * and generates a preview for the link
  */
  void handleTextLinks(String text) async {
    String link = getFirstValidLinkFromString(text);
    if (link.isNotEmpty) {
      previewLink = link;
      DecodeUrlRequest request =
          (DecodeUrlRequestBuilder()..url(previewLink)).build();
      DecodeUrlResponse response =
          await locator<LMFeedClient>().decodeUrl(request);
      if (response.success == true) {
        OgTags? responseTags = response.ogTags;
        linkModel = AttachmentPostViewData(
          mediaType: MediaType.link,
          link: previewLink,
          ogTags: OgTags(
            description: responseTags!.description,
            image: responseTags.image,
            title: responseTags.title,
            url: responseTags.url,
          ),
        );
        LMAnalytics.get().track(
          AnalyticsKeys.linkAttachedInPost,
          {
            'link': previewLink,
          },
        );
        locator<LMFeedBloc>().lmAnalyticsBloc.add(FireAnalyticEvent(
              eventName: AnalyticsKeys.linkAttachedInPost,
              eventProperties: {
                'link': previewLink,
              },
            ));
        if (postMedia.isEmpty) {
          rebuildLinkPreview.value = !rebuildLinkPreview.value;
        }
      }
    } else if (link.isEmpty) {
      linkModel = null;
      rebuildLinkPreview.value = !rebuildLinkPreview.value;
    }
  }

  /*
  * This function adds the link model in attachemnt
  * If the link model is not present in the attachment
  * and the link preview is enabled (no media is there)
  */
  void checkTextLinks() {
    String link = getFirstValidLinkFromString(_controller.text);
    if (link.isEmpty) {
      linkModel = null;
    } else if (linkModel != null && postMedia.isEmpty && showLinkPreview) {
      postMedia.add(linkModel!);
    }
  }

  @override
  Widget build(BuildContext context) {
    lmPostBloc = locator<LMFeedBloc>().lmPostBloc;
    Size screenSize = MediaQuery.of(context).size;
    ThemeData theme = LMThemeData.suraasaTheme;
    return WillPopScope(
      onWillPop: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Discard Post'),
            content: const Text(
                'Are you sure you want to discard the current post?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );

        return Future.value(false);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: LMThemeData.kWhiteColor,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 64.0, left: 16.0),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: FutureBuilder<GetTopicsResponse>(
                    future: getTopicsResponse,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data!.success == true) {
                        if (snapshot.data!.topics!.isNotEmpty) {
                          return ValueListenableBuilder(
                            valueListenable: rebuildTopicFloatingButton,
                            builder: (context, _, __) {
                              return GestureDetector(
                                onTap: () async {
                                  if (_focusNode.hasFocus) {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    currentFocus.unfocus();
                                    await Future.delayed(
                                        const Duration(milliseconds: 500));
                                  }
                                  _controllerPopUp.showMenu();
                                },
                                child: AbsorbPointer(
                                  child: CustomPopupMenu(
                                    controller: _controllerPopUp,
                                    showArrow: false,
                                    horizontalMargin: 16.0,
                                    pressType: PressType.singleClick,
                                    menuBuilder: () => TopicPopUp(
                                        selectedTopics: selectedTopic,
                                        isEnabled: true,
                                        onTopicSelected:
                                            (updatedTopics, tappedTopic) {
                                          if (selectedTopic.isEmpty) {
                                            selectedTopic.add(tappedTopic);
                                          } else {
                                            if (selectedTopic.first.id ==
                                                tappedTopic.id) {
                                              selectedTopic.clear();
                                            } else {
                                              selectedTopic.clear();
                                              selectedTopic.add(tappedTopic);
                                            }
                                          }
                                          _controllerPopUp.hideMenu();
                                          rebuildTopicFloatingButton.value =
                                              !rebuildTopicFloatingButton.value;
                                        }),
                                    child: Container(
                                      height: 36,
                                      alignment: Alignment.bottomLeft,
                                      margin: const EdgeInsets.only(left: 16.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(500),
                                        color: LMThemeData.kWhiteColor,
                                        border: Border.all(
                                          color: LMThemeData.kPrimaryColor,
                                        ),
                                      ),
                                      child: LMTopicChip(
                                        topic: selectedTopic.isEmpty
                                            ? (TopicUIBuilder()
                                                  ..id("0")
                                                  ..isEnabled(true)
                                                  ..name("Topic"))
                                                .build()
                                            : selectedTopic.first,
                                        textStyle: const TextStyle(
                                            color: LMThemeData.kPrimaryColor),
                                        icon: const LMIcon(
                                          type: LMIconType.icon,
                                          icon: CupertinoIcons.chevron_down,
                                          size: 16,
                                          color: LMThemeData.kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                LMThemeData.kVerticalPaddingMedium,
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 72.0,
                    bottom: 130.0,
                  ),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: LMProfilePicture(
                                fallbackText: user.name,
                                backgroundColor: LMThemeData.kPrimaryColor,
                                imageUrl: user.imageUrl,
                                onTap: () {
                                  if (user.sdkClientInfo != null) {
                                    locator<LMFeedClient>().routeToProfile(
                                        user.sdkClientInfo!.userUniqueId);
                                  }
                                },
                                size: 36,
                              ),
                            ),
                            LMThemeData.kHorizontalPaddingMedium,
                            Column(
                              children: [
                                Container(
                                  width: screenSize.width - 80,
                                  decoration: const BoxDecoration(
                                    color: LMThemeData.kWhiteColor,
                                  ),
                                  // constraints: BoxConstraints(
                                  //     maxHeight: screenSize.height * 0.8),
                                  child: TaggingAheadTextField(
                                    isDown: true,
                                    minLines: 3,
                                    // maxLines: 200,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                    ),
                                    onTagSelected: (tag) {
                                      userTags.add(tag);
                                    },
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    onChange: _onTextChanged,
                                  ),
                                ),
                                LMThemeData.kVerticalPaddingXLarge,
                                LMThemeData.kVerticalPaddingMedium,
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isUploading)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: LMThemeData.kPaddingMedium,
                              bottom: LMThemeData.kPaddingLarge,
                            ),
                            child: Center(
                              child: LMLoader(
                                color: LMThemeData.kPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: ValueListenableBuilder(
                            valueListenable: rebuildLinkPreview,
                            builder: (context, value, child) => (postMedia
                                        .isEmpty &&
                                    linkModel != null &&
                                    showLinkPreview)
                                ? Stack(
                                    children: [
                                      LMLinkPreview(
                                        linkModel: linkModel,
                                        backgroundColor:
                                            LMThemeData.kSecondary100,
                                        onTap: () {
                                          launchUrl(
                                            Uri.parse(
                                                linkModel?.ogTags?.url ?? ''),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        border: Border.all(
                                          color: LMThemeData.kSecondary100,
                                        ),
                                        title: LMTextView(
                                          text:
                                              linkModel?.ogTags?.title ?? "--",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                LMThemeData.kHeadingBlackColor,
                                            height: 1.30,
                                          ),
                                        ),
                                        subtitle: LMTextView(
                                          text:
                                              linkModel?.ogTags?.description ??
                                                  "--",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textStyle: const TextStyle(
                                            color:
                                                LMThemeData.kHeadingBlackColor,
                                            fontWeight: FontWeight.w400,
                                            height: 1.30,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: GestureDetector(
                                          onTap: () {
                                            LMAnalytics.get().track(
                                              AnalyticsKeys.linkAttachedInPost,
                                              {
                                                'link': previewLink,
                                              },
                                            );
                                            locator<LMFeedBloc>()
                                                .lmAnalyticsBloc
                                                .add(FireAnalyticEvent(
                                                  eventName: AnalyticsKeys
                                                      .linkAttachedInPost,
                                                  eventProperties: {
                                                    'link': previewLink,
                                                  },
                                                ));
                                            showLinkPreview = false;
                                            rebuildLinkPreview.value =
                                                !rebuildLinkPreview.value;
                                          },
                                          child: const CloseButtonIcon(),
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox()),
                      ),
                      if (postMedia.isNotEmpty)
                        postMedia.first.mediaType == MediaType.document
                            ? SliverToBoxAdapter(
                                child: getPostDocument(screenSize.width))
                            : SliverToBoxAdapter(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    top: LMThemeData.kPaddingSmall,
                                    left: 44.0,
                                  ),
                                  height: 200,
                                  alignment: Alignment.center,
                                  child: ListView.builder(
                                    itemCount: postMedia.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Stack(children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              child: Stack(
                                                children: [
                                                  postMedia[index].mediaType ==
                                                          MediaType.video
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                          child: Container(
                                                            height: 200,
                                                            width: 200,
                                                            color: Colors.black,
                                                            child: LMVideo(
                                                              videoFile:
                                                                  postMedia[
                                                                          index]
                                                                      .mediaFile!,
                                                              initialiseVideoController:
                                                                  (VideoController
                                                                      p0) {
                                                                videoController =
                                                                    p0;
                                                              },
                                                              boxFit: BoxFit
                                                                  .contain,
                                                              autoPlay: false,
                                                              showControls:
                                                                  false,
                                                              // width:
                                                              //     300,
                                                              borderRadius: 18,
                                                              isMute: true,
                                                            ),
                                                          ),
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          12)),
                                                          child: Container(
                                                            height: 200,
                                                            width: 200,
                                                            color: Colors.black,
                                                            child: LMImage(
                                                              boxFit: BoxFit
                                                                  .contain,
                                                              borderRadius: 18,
                                                              imageFile:
                                                                  postMedia[
                                                                          index]
                                                                      .mediaFile!,
                                                            ),
                                                          ),
                                                        ),
                                                  Positioned(
                                                    top: -8,
                                                    right: 0,
                                                    child: IconButton(
                                                        onPressed: () =>
                                                            removeAttachmenetAtIndex(
                                                                index),
                                                        icon: Icon(
                                                          CupertinoIcons
                                                              .xmark_circle_fill,
                                                          shadows: const [
                                                            Shadow(
                                                              offset:
                                                                  Offset(1, 1),
                                                              color: Colors
                                                                  .black38,
                                                            )
                                                          ],
                                                          color: LMThemeData
                                                              .kWhiteColor
                                                              .withOpacity(0.8),
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      ]);
                                    },
                                  ),
                                ),
                              ),
                      const SliverToBoxAdapter(
                        child: LMThemeData.kVerticalPaddingLarge,
                      ),
                    ],
                  ),
                ),
                PostComposerHeader(
                  onPressedBack: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Discard Post'),
                        content: const Text(
                            'Are you sure you want to discard the current post?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'No',
                              style:
                                  TextStyle(color: theme.colorScheme.primary),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              'Yes',
                              style:
                                  TextStyle(color: theme.colorScheme.primary),
                            ),
                            onPressed: () {
                              videoController?.player.pause();
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  title: const LMTextView(
                    text: "Create Post",
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LMThemeData.kGrey1Color,
                    ),
                  ),
                  onTap: () {
                    _focusNode.unfocus();

                    String postText = _controller.text;
                    postText = postText.trim();
                    if (postText.isNotEmpty || postMedia.isNotEmpty) {
                      if (selectedTopic.isEmpty) {
                        toast(
                          "Can't create a post without topic",
                          duration: Toast.LENGTH_LONG,
                        );
                        return;
                      }
                      checkTextLinks();
                      userTags =
                          TaggingHelper.matchTags(_controller.text, userTags);

                      result = TaggingHelper.encodeString(
                          _controller.text, userTags);

                      sendPostCreationCompletedEvent(
                          postMedia, userTags, selectedTopic);

                      lmPostBloc!.add(
                        CreateNewPost(
                          postText: result!,
                          postMedia: postMedia,
                          selectedTopics: selectedTopic,
                          user: user,
                        ),
                      );
                      videoController?.player.pause();
                      Navigator.pop(context);
                    } else {
                      toast(
                        "Can't create a post without text or attachments",
                        duration: Toast.LENGTH_LONG,
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    // height: 32,
                    decoration: BoxDecoration(
                      color: LMThemeData.kWhiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: LMThemeData.kGrey3Color.withOpacity(0.4),
                          offset: const Offset(0.0, -1.0),
                          blurRadius: 1.0,
                        ), //BoxShadow
                      ],
                    ),

                    child: isVideoAttached
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                isMediaPost
                                    ? LMIconButton(
                                        icon: LMIcon(
                                          type: LMIconType.svg,
                                          assetPath: kAssetGalleryIcon,
                                          color: LMThemeData
                                              .suraasaTheme.colorScheme.primary,
                                          boxPadding: 0,
                                          size: 44,
                                        ),
                                        onTap: (active) async {
                                          LMAnalytics.get().track(
                                              AnalyticsKeys.clickedOnAttachment,
                                              {'type': 'image'});
                                          locator<LMFeedBloc>()
                                              .lmAnalyticsBloc
                                              .add(FireAnalyticEvent(
                                                eventName: AnalyticsKeys
                                                    .clickedOnAttachment,
                                                eventProperties: const {
                                                  'type': 'image'
                                                },
                                              ));
                                          final result = await PostMediaPicker
                                              .handlePermissions(context, 1);
                                          if (result) {
                                            pickImages();
                                          }
                                        },
                                      )
                                    : const SizedBox.shrink(),
                                isMediaPost && postMedia.isEmpty
                                    ? const SizedBox(width: 8)
                                    : const SizedBox.shrink(),
                                isMediaPost && postMedia.isEmpty
                                    ? LMIconButton(
                                        icon: LMIcon(
                                          type: LMIconType.svg,
                                          assetPath: kAssetVideoIcon,
                                          color: LMThemeData
                                              .suraasaTheme.colorScheme.primary,
                                          boxPadding: 0,
                                          size: 44,
                                        ),
                                        onTap: (active) async {
                                          onUploading();
                                          locator<LMFeedBloc>()
                                              .lmAnalyticsBloc
                                              .add(FireAnalyticEvent(
                                                eventName: AnalyticsKeys
                                                    .clickedOnAttachment,
                                                eventProperties: const {
                                                  'type': 'video'
                                                },
                                              ));
                                          bool isAllowed = await PostMediaPicker
                                              .handlePermissions(context, 2);
                                          if (!isAllowed) {
                                            onUploadedMedia(false);
                                            return;
                                          }
                                          List<AttachmentPostViewData>?
                                              pickedMediaFiles =
                                              await PostMediaPicker.pickVideos(
                                                  postMedia.length,
                                                  onUploadedMedia);
                                          if (pickedMediaFiles != null &&
                                              pickedMediaFiles.isNotEmpty) {
                                            setPickedMediaFiles(
                                                pickedMediaFiles);
                                            onUploadedMedia(true);
                                          } else {
                                            onUploadedMedia(false);
                                          }
                                        },
                                      )
                                    : const SizedBox.shrink(),
                                isDocumentPost
                                    ? const SizedBox(width: 8)
                                    : const SizedBox.shrink(),
                                isDocumentPost
                                    ? LMIconButton(
                                        icon: LMIcon(
                                          type: LMIconType.svg,
                                          assetPath: kAssetDocPDFIcon,
                                          color: LMThemeData
                                              .suraasaTheme.colorScheme.primary,
                                          boxPadding: 0,
                                          size: 44,
                                        ),
                                        onTap: (active) async {
                                          if (postMedia.length >= 3) {
                                            //  TODO: Add your own toast message for document limit
                                            return;
                                          }
                                          onUploading();
                                          LMAnalytics.get().track(
                                              AnalyticsKeys.clickedOnAttachment,
                                              {'type': 'file'});
                                          locator<LMFeedBloc>()
                                              .lmAnalyticsBloc
                                              .add(FireAnalyticEvent(
                                                eventName: AnalyticsKeys
                                                    .clickedOnAttachment,
                                                eventProperties: const {
                                                  'type': 'file'
                                                },
                                              ));

                                          List<AttachmentPostViewData>?
                                              pickedMediaFiles =
                                              await PostMediaPicker
                                                  .pickDocuments(
                                                      postMedia.length);
                                          if (pickedMediaFiles != null) {
                                            setPickedMediaFiles(
                                                pickedMediaFiles);
                                            onUploadedDocument(true);
                                          } else {
                                            onUploadedDocument(false);
                                          }
                                        },
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTextChanged(String p0) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      handleTextLinks(p0);
    });
  }

  void pickImages() async {
    onUploading();
    try {
      final FilePickerResult? list = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      CommunityConfigurations config =
          await UserLocalPreference.instance.getCommunityConfigurations();
      if (config.value == null || config.value!["max_image_size"] == null) {
        final configResponse =
            await locator<LMFeedClient>().getCommunityConfigurations();
        if (configResponse.success &&
            configResponse.communityConfigurations != null &&
            configResponse.communityConfigurations!.isNotEmpty) {
          config = configResponse.communityConfigurations!.first;
        }
      }
      final double sizeLimit;
      if (config.value != null && config.value!["max_image_size"] != null) {
        sizeLimit = config.value!["max_image_size"]! / 1024;
      } else {
        sizeLimit = 5;
      }

      if (list != null && list.files.isNotEmpty) {
        if (postMedia.length + list.files.length > 10) {
          toast(
            'A total of 10 attachments can be added to a post',
            duration: Toast.LENGTH_LONG,
          );
          onUploadedMedia(false);
          return;
        }
        for (PlatformFile image in list.files) {
          int fileBytes = image.size;
          double fileSize = getFileSizeInDouble(fileBytes);
          if (fileSize > sizeLimit) {
            toast(
              'Max file size allowed: ${sizeLimit.toStringAsFixed(2)}MB',
              duration: Toast.LENGTH_LONG,
            );
            onUploadedMedia(false);
            return;
          }
        }
        List<File> pickedFiles = list.files.map((e) => File(e.path!)).toList();
        List<AttachmentPostViewData> mediaFiles = pickedFiles
            .map((e) => AttachmentPostViewData(
                mediaFile: File(e.path), mediaType: MediaType.image))
            .toList();
        setPickedMediaFiles(mediaFiles);
        onUploadedMedia(true);

        return;
      } else {
        onUploadedMedia(false);
        return;
      }
    } on Exception catch (err) {
      toast(
        'An error occurred',
        duration: Toast.LENGTH_LONG,
      );
      onUploadedMedia(false);
      debugPrint(err.toString());
      return;
    }
  }
}
