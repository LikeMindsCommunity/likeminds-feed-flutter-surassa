import 'dart:async';
import 'dart:io';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/packages/multi_image_crop/lib/multi_image_crop.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';
import 'package:likeminds_feed_ss_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/local_preference/user_local_preference.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_media_picker.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_utils.dart';
import 'package:likeminds_feed_ss_fl/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/post_composer_header.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/topic/topic_bottom_sheet.dart';
import 'package:likeminds_feed_ss_fl/src/widgets/topic/topic_popup.dart';

import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';

class NewPostScreen extends StatefulWidget {
  final String? populatePostText;
  final List<MediaModel>? populatePostMedia;

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
  ValueNotifier<bool> rebuildLinkPreview = ValueNotifier(false);
  List<TopicUI> selectedTopic = [];
  ValueNotifier<bool> rebuildTopicFloatingButton = ValueNotifier(false);
  CustomPopupMenuController _controllerPopUp = CustomPopupMenuController();

  NewPostBloc? newPostBloc;
  late final User user;

  List<MediaModel> postMedia = [];
  List<UserTag> userTags = [];
  String? result;

  bool isDocumentPost = false; // flag for document or media post
  bool isMediaPost = false;
  bool isUploading = false;

  String previewLink = '';
  MediaModel? linkModel;
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
    newPostBloc = BlocProvider.of<NewPostBloc>(context);
    if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }
  }

  void removeAttachmenetAtIndex(int index) {
    if (postMedia.isNotEmpty) {
      postMedia.removeAt(index);
      if (postMedia.isEmpty) {
        isDocumentPost = false;
        isMediaPost = false;
        showLinkPreview = true;
      }
      setState(() {});
    }
  }

  // this function initiliases postMedia list
  // with photos/videos picked by the user
  void setPickedMediaFiles(List<MediaModel> pickedMediaFiles) {
    if (postMedia.isEmpty) {
      postMedia = <MediaModel>[...pickedMediaFiles];
    } else {
      postMedia.addAll(pickedMediaFiles);
    }
  }

  /* Changes state to uploading
  for showing a circular loader while the user is
  picking files */
  void onUploading() {
    setState(() {
      isUploading = true;
    });
  }

  /* Changes state to uploaded
  for showing the picked files */
  void onUploadedMedia(bool uploadResponse) {
    if (uploadResponse) {
      isMediaPost = true;
      showLinkPreview = false;
      setState(() {
        isUploading = false;
      });
    } else {
      if (postMedia.isEmpty) {
        isMediaPost = false;
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
      setState(() {
        isUploading = false;
      });
    } else {
      if (postMedia.isEmpty) {
        isDocumentPost = false;
        showLinkPreview = true;
      }
      setState(() {
        isUploading = false;
      });
    }
  }

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
        documentFile: postMedia[index].mediaFile,
        onRemove: () => removeAttachmenetAtIndex(index),
      ),
    );
  }

  // void _onTextChanged(String p0) {
  //   if (_debounce?.isActive ?? false) {
  //     _debounce?.cancel();
  //   }
  //   _debounce = Timer(const Duration(milliseconds: 500), () {
  //     handleTextLinks(p0);
  //   });
  // }

  void handleTextLinks(String text) async {
    String link = getFirstValidLinkFromString(text);
    if (link.isNotEmpty) {
      previewLink = link;
      DecodeUrlRequest request =
          (DecodeUrlRequestBuilder()..url(previewLink)).build();
      DecodeUrlResponse response =
          await locator<LikeMindsService>().decodeUrl(request);
      if (response.success == true) {
        OgTags? responseTags = response.ogTags;
        linkModel = MediaModel(
          mediaType: MediaType.link,
          link: previewLink,
          ogTags: AttachmentMetaOgTags(
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
        if (postMedia.isEmpty) {
          rebuildLinkPreview.value = !rebuildLinkPreview.value;
        }
      }
    } else if (link.isEmpty) {
      linkModel = null;
      rebuildLinkPreview.value = !rebuildLinkPreview.value;
    }
  }

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
    newPostBloc = BlocProvider.of<NewPostBloc>(context);
    Size screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Discard Post'),
            content:
                const Text('Are you sure want to discard the current post?'),
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
          backgroundColor: kWhiteColor,
          body: SafeArea(
            child: Column(
              children: [
                PostComposerHeader(
                  onPressedBack: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Discard Post'),
                        content: const Text(
                            'Are you sure want to discard the current post?'),
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
                  },
                  title: "Create Post",
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
                      newPostBloc!.add(
                        CreateNewPost(
                          postText: result!,
                          postMedia: postMedia,
                          selectedTopics: selectedTopic,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      toast(
                        "Can't create a post without text or attachments",
                        duration: Toast.LENGTH_LONG,
                      );
                    }
                  },
                ),
                kVerticalPaddingMedium,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: LMProfilePicture(
                          fallbackText: user.name,
                          imageUrl: user.imageUrl,
                          onTap: () {
                            if (user.sdkClientInfo != null) {
                              locator<LikeMindsService>().routeToProfile(
                                  user.sdkClientInfo!.userUniqueId);
                            }
                          },
                          size: 36,
                        ),
                      ),
                      kHorizontalPaddingMedium,
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: kWhiteColor,
                              ),
                              child: TaggingAheadTextField(
                                isDown: true,
                                onTagSelected: (tag) {
                                  userTags.add(tag);
                                },
                                controller: _controller,
                                focusNode: _focusNode,
                                onChange: _onTextChanged,
                              ),
                            ),
                            kVerticalPaddingXLarge,
                            if (isUploading)
                              const Padding(
                                padding: EdgeInsets.only(
                                  top: kPaddingMedium,
                                  bottom: kPaddingLarge,
                                ),
                                child: LMLoader(),
                              ),
                            ValueListenableBuilder(
                                valueListenable: rebuildLinkPreview,
                                builder: (context, value, child) => (postMedia
                                            .isEmpty &&
                                        linkModel != null &&
                                        showLinkPreview)
                                    ? Stack(
                                        children: [
                                          LMLinkPreview(linkModel: linkModel),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () {
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
                            if (postMedia.isNotEmpty)
                              postMedia.first.mediaType == MediaType.document
                                  ? getPostDocument(screenSize.width)
                                  : Container(
                                      padding: const EdgeInsets.only(
                                        top: kPaddingSmall,
                                      ),
                                      height: 180,
                                      alignment: Alignment.center,
                                      child: ListView.builder(
                                        itemCount: postMedia.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            clipBehavior: Clip.hardEdge,
                                            child: Stack(
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      height: 180,
                                                      width: postMedia[index]
                                                                  .mediaType ==
                                                              MediaType.video
                                                          ? 300
                                                          : 180,
                                                      child: Stack(
                                                        children: [
                                                          postMedia[index]
                                                                      .mediaType ==
                                                                  MediaType
                                                                      .video
                                                              ? LMVideo(
                                                                  videoFile: postMedia[
                                                                          index]
                                                                      .mediaFile!,
                                                                  height: 180,
                                                                  boxFit: BoxFit
                                                                      .cover,
                                                                  showControls:
                                                                      false,
                                                                  width: 300,
                                                                )
                                                              : LMImage(
                                                                  height: 180,
                                                                  width: 180,
                                                                  boxFit: BoxFit
                                                                      .cover,
                                                                  borderRadius:
                                                                      18,
                                                                  imageFile: postMedia[
                                                                          index]
                                                                      .mediaFile!,
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                  ],
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
                                                        color: kWhiteColor
                                                            .withOpacity(0.5),
                                                      )),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            kVerticalPaddingMedium,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: ValueListenableBuilder(
                        valueListenable: rebuildTopicFloatingButton,
                        builder: (context, _, __) {
                          return CustomPopupMenu(
                            controller: _controllerPopUp,
                            showArrow: false,
                            verticalMargin: 0,
                            horizontalMargin: 0,
                            pressType: PressType.singleClick,
                            menuBuilder: () => TopicPopUp(
                                selectedTopics: selectedTopic,
                                onTopicSelected: (updatedTopics, tappedTopic) {
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
                              margin: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(500),
                                border: Border.all(
                                  color: kPrimaryColor,
                                  width: 1,
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
                                textStyle:
                                    const TextStyle(color: kPrimaryColor),
                                icon: const LMIcon(
                                  type: LMIconType.icon,
                                  icon: CupertinoIcons.chevron_down,
                                  size: 16,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: kGrey3Color.withOpacity(0.4),
                        offset: const Offset(0.0, -1.0),
                        blurRadius: 1.0,
                      ), //BoxShadow
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        isMediaPost
                            ? const SizedBox.shrink()
                            : LMIconButton(
                                icon: LMIcon(
                                  type: LMIconType.svg,
                                  assetPath: kAssetGalleryIcon,
                                  color: Theme.of(context).colorScheme.primary,
                                  boxPadding: 0,
                                  size: 44,
                                ),
                                onTap: (active) async {
                                  LMAnalytics.get().track(
                                      AnalyticsKeys.clickedOnAttachment,
                                      {'type': 'image'});
                                  final result =
                                      await handlePermissions(context, 1);
                                  if (result) {
                                    pickImages(context);
                                  }
                                },
                              ),
                        // isMediaPost
                        //     ? const SizedBox.shrink()
                        //     : const SizedBox(width: 8),
                        // isMediaPost
                        //     ? const SizedBox.shrink()
                        //     : LMIconButton(
                        //         icon: LMIcon(
                        //           type: LMIconType.svg,
                        //           assetPath: kAssetVideoIcon,
                        //           color:
                        //               Theme.of(context).colorScheme.secondary,
                        //           boxPadding: 0,
                        //           size: 44,
                        //         ),
                        //         onTap: (active) async {
                        //           onUploading();
                        //           List<MediaModel>? pickedMediaFiles =
                        //               await PostMediaPicker.pickVideos(
                        //                   postMedia.length);
                        //           if (pickedMediaFiles != null) {
                        //             setPickedMediaFiles(pickedMediaFiles);
                        //             onUploadedMedia(true);
                        //           } else {
                        //             onUploadedMedia(false);
                        //           }
                        //         },
                        //       ),
                        isDocumentPost
                            ? const SizedBox.shrink()
                            : const SizedBox(width: 8),
                        isDocumentPost
                            ? const SizedBox.shrink()
                            : LMIconButton(
                                icon: LMIcon(
                                  type: LMIconType.svg,
                                  assetPath: kAssetDocPDFIcon,
                                  color: Theme.of(context).colorScheme.primary,
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
                                  List<MediaModel>? pickedMediaFiles =
                                      await PostMediaPicker.pickDocuments(
                                          postMedia.length);
                                  if (pickedMediaFiles != null) {
                                    setPickedMediaFiles(pickedMediaFiles);
                                    onUploadedMedia(true);
                                  } else {
                                    onUploadedMedia(false);
                                  }
                                },
                              ),
                        const SizedBox(width: 8),
                        // LMIconButton(
                        //   icon: LMIcon(
                        //     type: LMIconType.svg,
                        //     assetPath: kAssetPollIcon,
                        //     color: Theme.of(context).colorScheme.secondary,
                        //     boxPadding: 0,
                        //     size: 44,
                        //   ),
                        //   onTap: (active) {},
                        // ),
                      ],
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

  Future<bool> handlePermissions(BuildContext context, int mediaType) async {
    if (Platform.isAndroid) {
      PermissionStatus permissionStatus;

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        if (mediaType == 1) {
          permissionStatus = await Permission.photos.status;
          if (permissionStatus == PermissionStatus.granted) {
            return true;
          } else if (permissionStatus == PermissionStatus.denied) {
            permissionStatus = await Permission.photos.request();
            if (permissionStatus == PermissionStatus.permanentlyDenied) {
              toast(
                'Permissions denied, change app settings',
                duration: Toast.LENGTH_LONG,
              );
              return false;
            } else if (permissionStatus == PermissionStatus.granted) {
              return true;
            } else {
              return false;
            }
          }
        } else {
          permissionStatus = await Permission.videos.status;
          if (permissionStatus == PermissionStatus.granted) {
            return true;
          } else if (permissionStatus == PermissionStatus.denied) {
            permissionStatus = await Permission.videos.request();
            if (permissionStatus == PermissionStatus.permanentlyDenied) {
              toast(
                'Permissions denied, change app settings',
                duration: Toast.LENGTH_LONG,
              );
              return false;
            } else if (permissionStatus == PermissionStatus.granted) {
              return true;
            } else {
              return false;
            }
          }
        }
      } else {
        permissionStatus = await Permission.storage.status;
        if (permissionStatus == PermissionStatus.granted) {
          return true;
        } else {
          permissionStatus = await Permission.storage.request();
          if (permissionStatus == PermissionStatus.granted) {
            return true;
          } else if (permissionStatus == PermissionStatus.denied) {
            return false;
          } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
            toast(
              'Permissions denied, change app settings',
              duration: Toast.LENGTH_LONG,
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  void pickImages(BuildContext context) async {
    onUploading();
    try {
      List<MediaModel> mediaFiles = [];
      final FilePickerResult? list = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (list != null && list.files.isNotEmpty) {
        if (postMedia.length + list.files.length > 10) {
          toast(
            'A total of 10 attachments can be added to a post',
            duration: Toast.LENGTH_LONG,
          );
          onUploadedDocument(false);
          return;
        }
        for (PlatformFile image in list.files) {
          int fileBytes = image.size;
          double fileSize = getFileSizeInDouble(fileBytes);
          if (fileSize > 100) {
            toast(
              'File size should be smaller than 100MB',
              duration: Toast.LENGTH_LONG,
            );
            onUploadedDocument(false);
            return;
          }
        }
        // MultiImageCrop.startCropping(
        //   context: context,
        //   activeColor: kWhiteColor,
        //   aspectRatio: 1,
        //   files: list.files.map((e) => File(e.path!)).toList(),
        //   callBack: (List<File> images) {
        //     List<MediaModel> mediaFiles = images
        //         .map((e) => MediaModel(
        //             mediaFile: File(e.path), mediaType: MediaType.image))
        //         .toList();
        //     setPickedMediaFiles(mediaFiles);
        //     onUploadedDocument(true);
        //     return;
        //   },
        // );
       
        mediaFiles = list.files
            .map((image) => MediaModel(
                mediaFile: File(image.path!), mediaType: MediaType.image))
            .toList();
        setPickedMediaFiles(mediaFiles);
        onUploadedDocument(false);
        return;
      } else {
        onUploadedDocument(false);
        return;
      }
    } catch (e) {
      toast(
        'An error occurred',
        duration: Toast.LENGTH_LONG,
      );
      onUploadedDocument(false);
      print(e.toString());
      return;
    }
  }
}
