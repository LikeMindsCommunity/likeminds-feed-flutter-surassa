import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';
import 'package:likeminds_feed_ss_fl/src/models/media_model.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';
import 'package:likeminds_feed_ss_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/local_preference/user_local_preference.dart';
import 'package:likeminds_feed_ss_fl/src/utils/tagging/tagging_textfield_ta.dart';

import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

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
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    user = UserLocalPreference.instance.fetchUserData();
    newPostBloc = BlocProvider.of<NewPostBloc>(context);
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

  // Widget getPostDocument(double width) {
  //   return ListView.builder(
  //     itemCount: postMedia.length,
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemBuilder: (context, index) => PostDocument(
  //       size: getFileSizeString(bytes: postMedia[index].size!),
  //       type: postMedia[index].format!,
  //       docFile: postMedia[index].mediaFile,
  //       removeAttachment: (index) => removeAttachmenetAtIndex(index),
  //       index: index,
  //     ),
  //   );
  // }

  // void _onTextChanged(String p0) {
  //   if (_debounce?.isActive ?? false) {
  //     _debounce?.cancel();
  //   }
  //   _debounce = Timer(const Duration(milliseconds: 500), () {
  //     handleTextLinks(p0);
  //   });
  // }

  // void handleTextLinks(String text) async {
  //   String link = getFirstValidLinkFromString(text);
  //   if (link.isNotEmpty) {
  //     previewLink = link;
  //     DecodeUrlRequest request =
  //         (DecodeUrlRequestBuilder()..url(previewLink)).build();
  //     DecodeUrlResponse response =
  //         await locator<LikeMindsService>().decodeUrl(request);
  //     if (response.success == true) {
  //       OgTags? responseTags = response.ogTags;
  //       linkModel = MediaModel(
  //         mediaType: MediaType.link,
  //         link: previewLink,
  //         ogTags: AttachmentMetaOgTags(
  //           description: responseTags!.description,
  //           image: responseTags.image,
  //           title: responseTags.title,
  //           url: responseTags.url,
  //         ),
  //       );
  //       LMAnalytics.get().logEvent(
  //         AnalyticsKeys.linkAttachedInPost,
  //         {
  //           'link': previewLink,
  //         },
  //       );
  //       if (postMedia.isEmpty) {
  //         setState(() {});
  //       }
  //     }
  //   } else if (link.isEmpty) {
  //     linkModel = null;
  //     setState(() {});
  //   }
  // }

  // void checkTextLinks() {
  //   String link = getFirstValidLinkFromString(_controller!.text);
  //   if (link.isEmpty) {
  //     linkModel = null;
  //   } else if (linkModel != null && postMedia.isEmpty && showLinkPreview) {
  //     postMedia.add(linkModel!);
  //   }
  // }

  // this function initiliases postMedia list
  // with photos/videos picked by the user
  // void setPickedMediaFiles(List<MediaModel> pickedMediaFiles) {
  //   if (postMedia.isEmpty) {
  //     postMedia = <MediaModel>[...pickedMediaFiles];
  //   } else {
  //     postMedia.addAll(pickedMediaFiles);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    newPostBloc = BlocProvider.of<NewPostBloc>(context);
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
        // if (postMedia.isNotEmpty ||
        //     (_controller != null && _controller!.text.isNotEmpty)) {
        //   showDialog(
        //       context: context,
        //       builder: (context) => AlertDialog(
        //             title: const Text('Discard Post'),
        //             content: const Text(
        //                 'Are you sure want to discard the current post?'),
        //             actions: <Widget>[
        //               TextButton(
        //                 child: const Text(
        //                   'NO',
        //                   style: TextStyle(fontSize: 14),
        //                 ),
        //                 onPressed: () {
        //                   Navigator.of(context).pop();
        //                 },
        //               ),
        //               TextButton(
        //                 child: const Text('Yes'),
        //                 onPressed: () {
        //                   Navigator.of(context).pop();
        //                   locator<NavigationService>().goBack(
        //                     result: {
        //                       "feedroomId": feedRoomId,
        //                       "isBack": false,
        //                       "feedRoomIds": feedRoomIds.isEmpty,
        //                     },
        //                   );
        //                 },
        //               ),
        //             ],
        //           ));
        // } else {
        //   locator<NavigationService>().goBack(
        //     result: {
        //       "feedroomId": feedRoomId,
        //       "isBack": false,
        //       "feedRoomIds": feedRoomIds,
        //     },
        //   );
        // }
        // return Future(() => false);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: kWhiteColor,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LMIconButton(
                          icon: LMIcon(
                            icon: Icons.chevron_left,
                            color: Theme.of(context).primaryColor,
                            size: 42,
                          ),
                          containerSize: 42,
                          onTap: (active) {
                            Navigator.pop(context);
                          },
                        ),
                        Spacer(),
                        const LMTextView(
                          text: 'Create a Post',
                          textStyle:
                              TextStyle(fontSize: 18, color: kGrey1Color),
                        ),
                        Spacer(),
                        LMTextButton(
                          text: LMTextView(
                            text: "Post",
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          width: 48,
                          borderRadius: 6,
                          backgroundColor: Theme.of(context).primaryColor,
                          onTap: (active) {
                            String postText = _controller!.text;
                            if (postText.isNotEmpty) {
                              newPostBloc!.add(
                                CreateNewPost(
                                  postText: postText,
                                  postMedia: postMedia,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                kVerticalPaddingLarge,
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
                                onTagSelected: (userTag) {},
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
                            // if (postMedia.isEmpty &&
                            //     linkModel != null &&
                            //     showLinkPreview)
                            //   Stack(
                            //     children: [
                            //       LMLinkPreview(
                            //           screenSize: screenSize, linkModel: linkModel),
                            //       Positioned(
                            //         top: 5,
                            //         right: 5,
                            //         child: GestureDetector(
                            //           onTap: () {
                            //             showLinkPreview = false;
                            //             setState(() {});
                            //           },
                            //           child: const CloseIcon(),
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            if (postMedia.isNotEmpty)
                              postMedia.first.mediaType == MediaType.document
                                  ? const SizedBox() //getPostDocument(screenSize!.width) const
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
                                          return Row(
                                            children: [
                                              LMImage(
                                                height: 180,
                                                width: 180,
                                                boxFit: BoxFit.cover,
                                                borderRadius: 18,
                                                imageFile:
                                                    postMedia[index].mediaFile!,
                                              ),
                                              const SizedBox(width: 8),
                                            ],
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
                Spacer(),
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
                        LMIconButton(
                          icon: LMIcon(
                            icon: Icons.photo_album_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 28,
                          ),
                          onTap: (active) async {
                            final result = await handlePermissions(context, 1);
                            if (result) {
                              pickImages(context);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        LMIconButton(
                          icon: LMIcon(
                            icon: Icons.videocam_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 28,
                          ),
                          onTap: (active) {},
                        ),
                        const SizedBox(width: 8),
                        LMIconButton(
                          icon: LMIcon(
                            icon: Icons.insert_drive_file_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 28,
                          ),
                          onTap: (active) {},
                        ),
                        const SizedBox(width: 8),
                        LMIconButton(
                          icon: LMIcon(
                            icon: Icons.checklist_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 28,
                          ),
                          onTap: (active) {},
                        ),
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

  String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

// Returns file size in double in MBs
  double getFileSizeInDouble(int bytes) {
    return (bytes / pow(1024, 2));
  }

  void _onTextChanged(String p0) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      handleTextLinks(p0);
    });
  }

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
        LMAnalytics.get().logEvent(
          AnalyticsKeys.linkAttachedInPost,
          {
            'link': previewLink,
          },
        );
        if (postMedia.isEmpty) {
          setState(() {});
        }
      }
    } else if (link.isEmpty) {
      linkModel = null;
      setState(() {});
    }
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
      final List<XFile> list = await ImagePicker().pickMultiImage();

      if (list.isNotEmpty) {
        if (postMedia.length + list.length > 10) {
          toast(
            'A total of 10 attachments can be added to a post',
            duration: Toast.LENGTH_LONG,
          );
          onUploadedDocument(false);
          return;
        }
        for (XFile image in list) {
          int fileBytes = await image.length();
          double fileSize = getFileSizeInDouble(fileBytes);
          if (fileSize > 100) {
            toast(
              'File size should be smaller than 100MB',
              duration: Toast.LENGTH_LONG,
            );
            onUploadedDocument(false);
            return;
          } else {
            final file = File(image.path);
            final mediaModel = MediaModel(
              mediaFile: file,
              mediaType: MediaType.image,
            );
            mediaFiles.add(mediaModel);
          }
        }
        setPickedMediaFiles(mediaFiles);
        onUploadedDocument(true);
      } else {
        onUploadedDocument(false);
      }
    } catch (e) {
      toast(
        'An error occurred',
        duration: Toast.LENGTH_LONG,
      );
      onUploadedDocument(false);
      print(e.toString());
    }
  }
}

// class AddAssetsButton extends StatelessWidget {
//   final ImagePicker picker;
//   final FilePicker filePicker;
//   final int mediaListLength;
//   final int mediaType; // 1 for photo 2 for video
//   final Function(bool uploadResponse) onUploaded;
//   final Function() uploading;
//   final Function() preUploadCheck;
//   final Function(List<MediaModel>)
//       postMedia; // only return in List<File> format

//   const AddAssetsButton({
//     super.key,
//     required this.mediaType,
//     required this.filePicker,
//     required this.mediaListLength,
//     required this.picker,
//     required this.onUploaded,
//     required this.uploading,
//     required this.postMedia,
//     required this.preUploadCheck,
//   });

//   void pickVideos() async {
//     uploading();
//     try {
//       final pickedFiles = await filePicker.pickFiles(
//         allowMultiple: true,
//         type: FileType.custom,
//         dialogTitle: 'Select files',
//         allowedExtensions: [
//           '3gp',
//           'mp4',
//         ],
//       );
//       if (pickedFiles != null) {
//         if (mediaListLength + pickedFiles.files.length > 10) {
//           toast(
//             'A total of 10 attachments can be added to a post',
//             duration: Toast.LENGTH_LONG,
//           );
//           onUploaded(false);
//           return;
//         }
//         List<MediaModel> videoFiles = [];
//         for (var pickedFile in pickedFiles.files) {
//           if (getFileSizeInDouble(pickedFile.size) > 100) {
//             toast(
//               'File size should be smaller than 100MB',
//               duration: Toast.LENGTH_LONG,
//             );
//             onUploaded(false);
//             return;
//           } else {
//             File video = File(pickedFile.path!);
//             VideoPlayerController controller =
//                 VideoPlayerController.file(video);
//             await controller.initialize();
//             Duration videoDuration = controller.value.duration;
//             MediaModel videoFile = MediaModel(
//                 mediaType: MediaType.video,
//                 mediaFile: video,
//                 duration: videoDuration.inSeconds);

//             videoFiles.add(videoFile);
//           }
//         }
//         postMedia(videoFiles);
//         onUploaded(true);
//         return;
//       } else {
//         onUploaded(false);
//         return;
//       }
//     } catch (e) {
//       onUploaded(false);
//       toast(
//         'An error occurred',
//         duration: Toast.LENGTH_LONG,
//       );
//       print(e.toString());
//       return;
//     }
//   }

//   void pickFiles() async {
//     uploading();
//     try {
//       final pickedFiles = await filePicker.pickFiles(
//         allowMultiple: true,
//         type: FileType.custom,
//         dialogTitle: 'Select files',
//         allowedExtensions: [
//           'pdf',
//         ],
//       );

//       if (pickedFiles != null) {
//         if (mediaListLength + pickedFiles.files.length > 10) {
//           toast(
//             'A total of 10 attachments can be added to a post',
//             duration: Toast.LENGTH_LONG,
//           );
//           onUploaded(false);
//           return;
//         }
//         for (var pickedFile in pickedFiles.files) {
//           if (getFileSizeInDouble(pickedFile.size) > 100) {
//             toast(
//               'File size should be smaller than 100MB',
//               duration: Toast.LENGTH_LONG,
//             );
//             onUploaded(false);
//             return;
//           }
//         }
//         List<MediaModel> attachedFiles = [];
//         attachedFiles = pickedFiles.files
//             .map((e) => MediaModel(
//                 mediaType: MediaType.document,
//                 mediaFile: File(e.path!),
//                 format: e.extension,
//                 size: e.size))
//             .toList();
//         postMedia(attachedFiles);
//         onUploaded(true);
//       } else {
//         onUploaded(false);
//       }
//     } catch (e) {
//       onUploaded(false);
//       toast(
//         'An error occurred',
//         duration: Toast.LENGTH_LONG,
//       );
//       print(e.toString());
//       return;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size screenSize = MediaQuery.of(context).size;
//     return GestureDetector(
//       onTap: () async {
//         LMAnalytics.get().logEvent(
//           AnalyticsKeys.clickedOnAttachment,
//           {
//             'type': mediaType == 1
//                 ? 'photo'
//                 : mediaType == 2
//                     ? 'video'
//                     : 'file',
//           },
//         );
//         if (preUploadCheck()) {
//           bool permissionStatus = await handlePermissions(context);
//           if (permissionStatus) {
//             if (mediaType == 1) {
//               pickImages(context);
//             } else if (mediaType == 2) {
//               pickVideos();
//             } else if (mediaType == 3) {
//               pickFiles();
//             }
//           }
//         } else {
//           toast(
//             "A total of 10 attachments can be added to a post",
//             duration: Toast.LENGTH_LONG,
//           );
//         }
//       },
//       child: SizedBox(
//         height: 48,
//         width: screenSize.width,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//             vertical: 10,
//           ),
//           child: Row(
//             children: [
//               SvgPicture.asset(
//                 assetButtonData[mediaType]['svg_icon'],
//                 height: 28,
//               ),
//               kHorizontalPaddingLarge,
//               Text(
//                 assetButtonData[mediaType]['title'],
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: kGreyColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
