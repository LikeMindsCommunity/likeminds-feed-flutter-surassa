part of '../post_bloc.dart';

Future<void> editPostEventHandler(
    EditPost event, Emitter<LMPostState> emit) async {
  try {
    emit(EditPostUploading());
    List<Attachment>? attachments = event.attachments;
    String postText = event.postText;

    var response =
        await locator<LMFeedClient>().editPost((EditPostRequestBuilder()
              ..attachments(attachments ?? [])
              ..postId(event.postId)
              ..postText(postText))
            .build());

    if (response.success) {
      emit(
        EditPostUploaded(
          postData: PostUI.fromPost(post: response.post!),
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
      emit(
        NewPostError(
          message: response.errorMessage!,
        ),
      );
    }
  } catch (err) {
    emit(
      const NewPostError(
        message: 'An error occurred while saving the post',
      ),
    );
  }
}
