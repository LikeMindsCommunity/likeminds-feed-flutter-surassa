import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:likeminds_feed_ss_fl/src/utils/post/post_utils.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class PostMediaPicker {
  static Future<bool> handlePermissions(
      BuildContext context, int mediaType) async {
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
              // TODO: Add your own toast
              // toast(
              //   'Permissions denied, change app settings',
              //   duration: Toast.LENGTH_LONG,
              // );
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
              // TODO: Add your own toast
              // toast(
              //   'Permissions denied, change app settings',
              //   duration: Toast.LENGTH_LONG,
              // );
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
            // TODO: Add your own toast
            // toast(
            //   'Permissions denied, change app settings',
            //   duration: Toast.LENGTH_LONG,
            // );
            return false;
          }
        }
      }
    }
    return true;
  }

  static Future<List<File>> pickPhotos() async {
    return [];
  }

  static Future<List<MediaModel>?> pickVideos(int currentMediaLength) async {
    try {
      final XFile? pickedFile =
          await ImagePicker().pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (currentMediaLength + 1 > 10) {
          // TODO: Add your own toast
          // toast(
          //   'A total of 10 attachments can be added to a post',
          //   duration: Toast.LENGTH_LONG,
          // );
          return null;
        } else {
          List<MediaModel> videoFiles = [];
          int fileBytes = await pickedFile!.length();
          double fileSize = getFileSizeInDouble(fileBytes);
          if (fileSize > 100) {
            // TODO: Add your own toast
            // toast(
            //   'File size should be smaller than 100MB',
            //   duration: Toast.LENGTH_LONG,
            // );
          } else {
            File video = File(pickedFile.path);
            VideoPlayerController controller = VideoPlayerController.file(
              video,
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: false,
              ),
            );
            await controller.initialize();
            Duration videoDuration = controller.value.duration;
            MediaModel videoFile = MediaModel(
              mediaType: MediaType.video,
              mediaFile: video,
              duration: videoDuration.inSeconds,
              size: fileBytes,
            );
            videoFiles.add(videoFile);
            controller.dispose();
          }

          return videoFiles;
        }
      } else {
        return null;
      }
    } catch (e) {
      // TODO: Add your own toast
      // toast(
      //   'An error occurred',
      //   duration: Toast.LENGTH_LONG,
      // );
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<List<MediaModel>?> pickDocuments(int currentMediaLength) async {
    try {
      final pickedFiles = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        dialogTitle: 'Select files',
        allowedExtensions: [
          'pdf',
        ],
      );
      if (pickedFiles != null) {
        if (currentMediaLength + pickedFiles.files.length > 10) {
          // TODO: Add your own toast
          // toast(
          //   'A total of 10 attachments can be added to a post',
          //   duration: Toast.LENGTH_LONG,
          // );
          return null;
        }
        List<MediaModel> attachedFiles = [];
        for (var pickedFile in pickedFiles.files) {
          if (getFileSizeInDouble(pickedFile.size) > 100) {
            // TODO: Add your own toast
            // toast(
            //   'File size should be smaller than 100MB',
            //   duration: Toast.LENGTH_LONG,
            // );
          } else {
            MediaModel videoFile = MediaModel(
                mediaType: MediaType.document,
                mediaFile: File(pickedFile.path!),
                format: pickedFile.extension,
                size: pickedFile.size);
            attachedFiles.add(videoFile);
          }
        }
        return attachedFiles;
      } else {
        return null;
      }
    } catch (e) {
      // TODO: Add your own toast
      // toast(
      //   'An error occurred',
      //   duration: Toast.LENGTH_LONG,
      // );
      return null;
    }
  }
}
