import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/bloc.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/post_bloc/post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_utils.dart';
import 'package:likeminds_feed_ss_fl/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/post_composer_header.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

class EditPostScreen extends StatefulWidget {
  static const String route = '/edit_post_screen';
  final String postId;

  const EditPostScreen({
    super.key,
    required this.postId,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late Future<GetPostResponse> postFuture;
  final FocusNode _focusNode = FocusNode();
  TextEditingController? textEditingController;
  ValueNotifier<bool> rebuildAttachments = ValueNotifier(false);
  late String postId;
  Post? postDetails;
  LMPostBloc? newPostBloc;
  List<Attachment>? attachments;
  User? user;
  bool isDocumentPost = false; // flag for document or media post
  bool isMediaPost = false;
  String previewLink = '';
  String convertedPostText = '';
  MediaModel? linkModel;
  List<UserTag> userTags = [];
  bool showLinkPreview =
      true; // if set to false link preview should not be displayed
  Timer? _debounce;
  Size? screenSize;

  @override
  void dispose() {
    _debounce?.cancel();
    textEditingController?.dispose();
    rebuildAttachments.dispose();
    super.dispose();
  }

  void _onTextChanged(String p0) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      handleTextLinks(p0);
    });
  }

  Widget getPostDocument(double width) {
    return ListView.builder(
      itemCount: attachments!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => LMDocument(
        size:
            getFileSizeString(bytes: attachments![index].attachmentMeta.size!),
        type: attachments![index].attachmentMeta.format!,
        documentIcon: const LMIcon(
          type: LMIconType.svg,
          assetPath: kAssetPDFIcon,
          size: 20,
        ),
        documentUrl: attachments![index].attachmentMeta.url,
        onTap: () {
          Uri fileUrl = Uri.parse(attachments![index].attachmentMeta.url!);
          launchUrl(fileUrl, mode: LaunchMode.platformDefault);
        },
      ),
    );
  }

  void handleTextLinks(String text) async {
    String link = getFirstValidLinkFromString(text);
    if (link.isNotEmpty && showLinkPreview) {
      previewLink = link;
      DecodeUrlRequest request =
          (DecodeUrlRequestBuilder()..url(previewLink)).build();
      DecodeUrlResponse response =
          await locator<LMFeedClient>().decodeUrl(request);
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
      }
      rebuildAttachments.value = !rebuildAttachments.value;
    } else if (link.isEmpty) {
      linkModel = null;
      attachments?.removeWhere((element) => element.attachmentType == 4);
      rebuildAttachments.value = !rebuildAttachments.value;
    }
  }

  @override
  void initState() {
    super.initState();
    user = UserLocalPreference.instance.fetchUserData();
    postId = widget.postId;
    textEditingController = TextEditingController();
    postFuture = locator<LMFeedClient>().getPost((GetPostRequestBuilder()
          ..postId(widget.postId)
          ..page(1)
          ..pageSize(10))
        .build());
    if (_focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }
  }

  void checkTextLinks() {
    String link = getFirstValidLinkFromString(textEditingController!.text);
    if (link.isEmpty) {
      linkModel = null;
      attachments?.removeWhere((element) => element.attachmentType == 4);
    } else if (linkModel != null &&
        showLinkPreview &&
        !isDocumentPost &&
        !isMediaPost) {
      attachments = [
        Attachment(
          attachmentType: 4,
          attachmentMeta: AttachmentMeta(
            url: linkModel?.link,
            ogTags: AttachmentMetaOgTags(
              description: linkModel?.ogTags?.description,
              image: linkModel?.ogTags?.image,
              title: linkModel?.ogTags?.title,
              url: linkModel?.ogTags?.url,
            ),
          ),
        ),
      ];
    } else if (!showLinkPreview) {
      attachments?.removeWhere((element) => element.attachmentType == 4);
    }
  }

  void setPostData(Post post) {
    if (postDetails == null) {
      postDetails = post;
      convertedPostText = TaggingHelper.convertRouteToTag(post.text);
      textEditingController!.value = TextEditingValue(text: convertedPostText);
      textEditingController!.selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController!.text.length));
      userTags = TaggingHelper.addUserTagsIfMatched(post.text);
      attachments = post.attachments ?? [];
      if (attachments != null && attachments!.isNotEmpty) {
        if (attachments![0].attachmentType == 1 ||
            attachments![0].attachmentType == 2) {
          isMediaPost = true;
          showLinkPreview = false;
        } else if (attachments![0].attachmentType == 3) {
          isDocumentPost = true;
          showLinkPreview = false;
        } else if (attachments![0].attachmentType == 4) {
          linkModel = MediaModel(
              mediaType: MediaType.link,
              link: attachments![0].attachmentMeta.url,
              ogTags: attachments![0].attachmentMeta.ogTags);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    newPostBloc = locator<LMFeedBloc>().lmPostBloc;
    return WillPopScope(
      onWillPop: () {
        if (textEditingController!.text != convertedPostText) {
          showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                    title: const Text('Discard Changes'),
                    content: const Text(
                        'Are you sure want to discard the current changes?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text(
                          'NO',
                          style: TextStyle(fontSize: 14),
                        ),
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
                  ));
        } else {
          Navigator.of(context).pop();
        }
        return Future(() => false);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: LMThemeData.kWhiteColor,
          body: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: LMThemeData.kWhiteColor,
              body: FutureBuilder(
                  future: postFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: LMLoader(
                        color: LMThemeData.kPrimaryColor,
                      ));
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      GetPostResponse response = snapshot.data!;
                      if (response.success) {
                        setPostData(response.post!);
                        return postEditWidget();
                      } else {
                        return postErrorScreen(response.errorMessage!);
                      }
                    }
                    return const SizedBox();
                  }),
            ),
          ),
        ),
      ),
    );
  }

  Widget postErrorScreen(String error) {
    return Center(
      child: Text(error),
    );
  }

  Widget postEditWidget() {
    return Column(
      children: <Widget>[
        PostComposerHeader(
          onPressedBack: () {
            if (textEditingController!.text != convertedPostText) {
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
                      ));
            } else {
              Navigator.of(context).pop();
            }
          },
          title: const LMTextView(
            text: "Edit Post",
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: LMThemeData.kGrey1Color,
            ),
          ),
          onTap: () async {
            if (textEditingController!.text.isNotEmpty ||
                (postDetails!.attachments != null &&
                    postDetails!.attachments!.isNotEmpty)) {
              checkTextLinks();
              userTags = TaggingHelper.matchTags(
                  textEditingController!.text, userTags);
              String result = TaggingHelper.encodeString(
                  textEditingController!.text, userTags);
              newPostBloc?.add(EditPost(
                postText: result,
                attachments: attachments,
                postId: postId,
                selectedTopics: const [],
              ));
              Navigator.of(context).pop();
            } else {
              toast(
                "Can't save a post without text or attachments",
                duration: Toast.LENGTH_LONG,
              );
            }
          },
        ),
        LMThemeData.kVerticalPaddingMedium,
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
                  fallbackText: user!.name,
                  backgroundColor: LMThemeData.kPrimaryColor,
                  imageUrl: user!.imageUrl,
                  onTap: () {
                    if (user!.sdkClientInfo != null) {
                      locator<LMFeedClient>()
                          .routeToProfile(user!.sdkClientInfo!.userUniqueId);
                    }
                  },
                  size: 36,
                ),
              ),
              LMThemeData.kHorizontalPaddingMedium,
              Expanded(
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: LMThemeData.kWhiteColor,
                      ),
                      child: TaggingAheadTextField(
                        isDown: true,
                        onTagSelected: (tag) {
                          userTags.add(tag);
                        },
                        controller: textEditingController!,
                        focusNode: _focusNode,
                        onChange: _onTextChanged,
                      ),
                    ),
                    LMThemeData.kVerticalPaddingXLarge,
                    ValueListenableBuilder(
                        valueListenable: rebuildAttachments,
                        builder: (context, value, child) =>
                            ((attachments == null || attachments!.isEmpty) &&
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
                                            rebuildAttachments.value =
                                                !rebuildAttachments.value;
                                          },
                                          child: const CloseButtonIcon(),
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox()),
                    if (attachments != null && attachments!.isNotEmpty)
                      mapIntToMediaType(attachments!.first.attachmentType) ==
                              MediaType.document
                          ? getPostDocument(screenSize!.width)
                          : Container(
                              padding: const EdgeInsets.only(
                                top: LMThemeData.kPaddingSmall,
                                left: 44.0,
                              ),
                              height: 180,
                              alignment: Alignment.center,
                              child: ListView.builder(
                                itemCount: attachments!.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(18.0),
                                    clipBehavior: Clip.hardEdge,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 180,
                                          width: mapIntToMediaType(
                                                      attachments![index]
                                                          .attachmentType) ==
                                                  MediaType.video
                                              ? 300
                                              : 180,
                                          child: Stack(
                                            children: [
                                              mapIntToMediaType(attachments![
                                                              index]
                                                          .attachmentType) ==
                                                      MediaType.video
                                                  ? LMVideo(
                                                      videoUrl:
                                                          attachments![index]
                                                              .attachmentMeta
                                                              .url!,
                                                      height: 180,
                                                      boxFit: BoxFit.cover,
                                                      showControls: false,
                                                      width: 300,
                                                    )
                                                  : LMImage(
                                                      height: 180,
                                                      width: 180,
                                                      boxFit: BoxFit.cover,
                                                      borderRadius: 18,
                                                      imageUrl:
                                                          attachments![index]
                                                              .attachmentMeta
                                                              .url!,
                                                    ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    LMThemeData.kVerticalPaddingMedium,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
