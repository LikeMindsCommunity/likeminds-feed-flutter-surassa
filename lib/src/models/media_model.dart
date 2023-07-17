import 'dart:io';

import 'package:likeminds_feed/likeminds_feed.dart';

enum MediaType { video, image, document, link }

class MediaModel {
  // defines the type of media
  MediaType mediaType;
  // one of mediaFile or link must be provided
  File? mediaFile; // Photo Video or Document File
  String? link; // Photo Video, Document or Link Preview URL
  int? duration; // required for video url
  String? format; // required for documents
  int? size; // required for documents
  AttachmentMetaOgTags? ogTags; // required for links (attachment type 4)

  MediaModel({
    required this.mediaType,
    this.mediaFile,
    this.link,
    this.duration,
    this.format,
    this.size,
    this.ogTags,
  });

  // convert
  int mapMediaTypeToInt() {
    if (mediaType == MediaType.image) {
      return 1;
    } else if (mediaType == MediaType.video) {
      return 2;
    } else if (mediaType == MediaType.document) {
      return 3;
    } else if (mediaType == MediaType.link) {
      return 4;
    } else {
      throw 'no valid media type provided';
    }
  }
}
