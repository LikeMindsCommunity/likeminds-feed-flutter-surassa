import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/models/media_model.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';
import 'package:likeminds_feed_ss_fl/src/utils/analytics/analytics.dart';
import 'package:likeminds_feed_ss_fl/src/utils/local_preference/user_local_preference.dart';

part 'new_post_event.dart';
part 'new_post_state.dart';

class NewPostBloc extends Bloc<NewPostEvents, NewPostState> {
  NewPostBloc() : super(NewPostInitiate()) {
    on<NewPostEvents>((event, emit) async {
      if (event is CreateNewPost) {
        try {
          List<MediaModel>? postMedia = event.postMedia;
          User user = UserLocalPreference.instance.fetchUserData();
          int imageCount = 0;
          int videoCount = 0;
          int documentCount = 0;
          List<Attachment> attachments = [];
          int index = 0;

          StreamController<double> progress =
              StreamController<double>.broadcast();
          progress.add(0);

          // Upload post media to s3 and add links as Attachments
          if (postMedia != null && postMedia.isNotEmpty) {
            emit(
              NewPostUploading(
                progress: progress.stream,
                thumbnailMedia: postMedia.isEmpty
                    ? null
                    : postMedia[0].mediaType == MediaType.link
                        ? null
                        : postMedia[0],
              ),
            );
            for (final media in postMedia) {
              if (media.mediaType == MediaType.link) {
                attachments.add(
                  Attachment(
                    attachmentType: 4,
                    attachmentMeta: AttachmentMeta(
                        url: media.ogTags!.url,
                        ogTags: AttachmentMetaOgTags(
                          description: media.ogTags!.description,
                          image: media.ogTags!.image,
                          title: media.ogTags!.title,
                          url: media.ogTags!.url,
                        )),
                  ),
                );
              } else {
                File mediaFile = media.mediaFile!;
                index += 1;
                final String? response = await locator<LikeMindsService>()
                    .uploadFile(mediaFile, user.userUniqueId);
                if (response != null) {
                  attachments.add(Attachment(
                    attachmentType: media.mapMediaTypeToInt(),
                    attachmentMeta: AttachmentMeta(
                        url: response,
                        size: media.mediaType == MediaType.document
                            ? media.size
                            : null,
                        format: media.mediaType == MediaType.document
                            ? media.format
                            : null,
                        duration: media.mediaType == MediaType.video
                            ? media.duration
                            : null),
                  ));
                  progress.add(index / postMedia.length);
                } else {
                  throw ('Error uploading file');
                }
              }
            }
            // For counting the no of attachments
            for (final attachment in attachments) {
              if (attachment.attachmentType == 1) {
                imageCount++;
              } else if (attachment.attachmentType == 2) {
                videoCount++;
              } else if (attachment.attachmentType == 3) {
                documentCount++;
              }
            }
          } else {
            emit(
              NewPostUploading(
                progress: progress.stream,
              ),
            );
          }
          final AddPostRequest request = (AddPostRequestBuilder()
                ..text(event.postText)
                ..attachments(attachments))
              .build();

          final AddPostResponse response =
              await locator<LikeMindsService>().addPost(request);

          if (response.success) {
            LMAnalytics.get().track(
              AnalyticsKeys.postCreationCompleted,
              {
                "user_tagged": "no",
                "link_attached": "no",
                "image_attached": imageCount == 0
                    ? "no"
                    : {
                        "yes": {
                          "image_count": imageCount,
                        },
                      },
                "video_attached": videoCount == 0
                    ? "no"
                    : {
                        "yes": {
                          "video_count": videoCount,
                        },
                      },
                "document_attached": documentCount == 0
                    ? "no"
                    : {
                        "yes": {
                          "document_count": documentCount,
                        },
                      },
              },
            );
            emit(NewPostUploaded(
                postData: response.post!, userData: response.user!));
          } else {
            emit(NewPostError(message: response.errorMessage!));
          }
        } catch (err) {
          emit(const NewPostError(message: 'An error occurred'));
          print(err.toString());
        }
      }
      if (event is EditPost) {
        try {
          emit(EditPostUploading());
          List<Attachment>? attachments = event.attachments;
          String postText = event.postText;

          var response = await locator<LikeMindsService>()
              .editPost((EditPostRequestBuilder()
                    ..attachments(attachments ?? [])
                    ..postId(event.postId)
                    ..postText(postText))
                  .build());

          if (response.success) {
            emit(
              EditPostUploaded(
                postData: response.post!,
                userData: response.user!,
              ),
            );
          } else {
            emit(
              NewPostError(
                message: response.errorMessage!,
              ),
            );
          }
        } catch (err) {
          emit(
            const NewPostError(
              message: 'An error occured while saving the post',
            ),
          );
        }
      }
    });
  }
}
