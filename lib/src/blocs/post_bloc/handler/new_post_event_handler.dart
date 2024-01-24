part of '../post_bloc.dart';

newPostEventHandler(CreateNewPost event, Emitter<LMPostState> emit) async {
  try {
    List<AttachmentPostViewData>? postMedia = event.postMedia;
    List<Attachment> attachments = [];
    int index = 0;

    StreamController<double> progress = StreamController<double>.broadcast();
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
                  ogTags: OgTags(
                    description: media.ogTags!.description,
                    image: media.ogTags!.image,
                    title: media.ogTags!.title,
                    url: media.ogTags!.url,
                  )),
            ),
          );
        } else {
          File mediaFile = media.mediaFile!;
          final String? response = await locator<MediaService>()
              .uploadFile(mediaFile, event.user.userUniqueId);
          if (response != null) {
            attachments.add(
              Attachment(
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
              ),
            );
            progress.add(index / postMedia.length);
          } else {
            throw ('Error uploading file');
          }
        }
      }
      // For counting the no of attachments
    } else {
      emit(
        NewPostUploading(
          progress: progress.stream,
        ),
      );
    }
    List<Topic> postTopics =
        event.selectedTopics.map((e) => e.toTopic()).toList();
    final AddPostRequest request = (AddPostRequestBuilder()
          ..text(event.postText)
          ..attachments(attachments)
          ..topics(postTopics))
        .build();

    final AddPostResponse response =
        await locator<LMFeedClient>().addPost(request);

    if (response.success) {
      emit(
        NewPostUploaded(
          postData: PostViewData.fromPost(post: response.post!),
          userData: response.user!,
          topics: (response.topics ?? <String, Topic>{}).map(
            (key, value) => MapEntry(
              key,
              TopicUI.fromTopic(value),
            ),
          ),
        ),
      );
    } else {
      emit(NewPostError(message: response.errorMessage!));
    }
  } on Exception catch (err) {
    emit(const NewPostError(message: 'An error occurred'));
    debugPrint(err.toString());
  }
}
