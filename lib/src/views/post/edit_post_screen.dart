import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/local_preference/user_local_preference.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_utils.dart';
import 'package:likeminds_feed_ss_fl/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/post_composer_header.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

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
  TextEditingController? textEditingController;
  ValueNotifier<bool> rebuildAttachments = ValueNotifier(false);
  late String postId;
  Post? postDetails;
  NewPostBloc? newPostBloc;
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
    postFuture = locator<LikeMindsService>().getPost((GetPostRequestBuilder()
          ..postId(widget.postId)
          ..page(1)
          ..pageSize(10))
        .build());
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
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    screenSize = MediaQuery.of(context).size;
    newPostBloc = BlocProvider.of<NewPostBloc>(context);
    return WillPopScope(
      onWillPop: () {
        if (textEditingController!.text != convertedPostText) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
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
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          Navigator.of(context).pop();
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
          backgroundColor: kWhiteColor,
          body: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: kWhiteColor,
              body: FutureBuilder(
                  future: postFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
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
                  builder: (context) => AlertDialog(
                        title: const Text('Discard Post'),
                        content: const Text(
                            'Are you sure want to discard the current post?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ));
            } else {
              Navigator.of(context).pop();
            }
          },
          title: "Edit Post",
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
        kVerticalPaddingMedium,
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
          child: Row(
            children: [
              LMProfilePicture(
                imageUrl: user!.imageUrl,
                fallbackText: user!.name,
              ),
              kHorizontalPaddingLarge,
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 72,
                  ),
                  decoration: const BoxDecoration(
                    color: kWhiteColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TaggingAheadTextField(
                      focusNode: FocusNode(),
                      isDown: true,
                      controller: textEditingController!,
                      onTagSelected: (tag) {
                        print(tag);
                        userTags.add(tag);
                      },
                      onChange: (p0) {
                        _onTextChanged(p0);
                      },
                    ),
                  ),
                ),
                kVerticalPaddingXLarge,
                ValueListenableBuilder(
                    valueListenable: rebuildAttachments,
                    builder: (context, _, __) {
                      if (linkModel != null && showLinkPreview) {
                        return Stack(children: [
                          // PostLinkView(
                          //     screenSize: screenSize, linkModel: linkModel),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                showLinkPreview = false;
                                attachments?.clear();
                                rebuildAttachments.value =
                                    !rebuildAttachments.value;
                              },
                              child: const CloseButtonIcon(),
                            ),
                          )
                        ]);
                      } else {
                        return const SizedBox();
                      }
                    }),
                if (attachments != null && attachments!.isNotEmpty)
                  attachments!.first.attachmentType == 3
                      ? getPostDocument(screenSize!.width)
                      : Container(
                          padding: const EdgeInsets.only(
                            top: kPaddingSmall,
                          ),
                          alignment: Alignment.center,
                          // child: PostMedia(
                          //   height: screenSize!.width,
                          //   attachments: attachments,
                          //   postId: postId,
                          // ),
                        ),
                kVerticalPaddingMedium,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
