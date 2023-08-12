part of 'new_post_bloc.dart';

abstract class NewPostState extends Equatable {
  const NewPostState();

  @override
  List<Object> get props => [];
}

class NewPostInitiate extends NewPostState {}

class NewPostUploading extends NewPostState {
  final Stream<double> progress;
  final MediaModel? thumbnailMedia;

  const NewPostUploading({required this.progress, this.thumbnailMedia});
}

class EditPostUploading extends NewPostState {}

class NewPostUploaded extends NewPostState {
  final PostViewModel postData;
  final Map<String, User> userData;

  const NewPostUploaded({required this.postData, required this.userData});
}

class EditPostUploaded extends NewPostState {
  final PostViewModel postData;
  final Map<String, User> userData;

  const EditPostUploaded({required this.postData, required this.userData});
}

class NewPostError extends NewPostState {
  final String message;

  const NewPostError({required this.message});
}

class PostDeletionError extends NewPostState {
  final String message;

  const PostDeletionError({required this.message});

  @override
  List<Object> get props => [message];
}

class PostDeleted extends NewPostState {
  final String postId;

  const PostDeleted({required this.postId});

  @override
  List<Object> get props => [postId];
}

class PostUpdateState extends NewPostState {
  final PostViewModel post;

  const PostUpdateState({required this.post});

  @override
  List<Object> get props => [post];
}

class PostPinnedState extends NewPostState {
  final String postId;
  final bool isPinned;

  const PostPinnedState({required this.postId, required this.isPinned});

  @override
  List<Object> get props => [postId, isPinned];
}

class PostPinError extends NewPostState {
  final String message;
  final bool isPinned;
  final String postId;

  const PostPinError({
    required this.message,
    required this.isPinned,
    required this.postId,
  });

  @override
  List<Object> get props => [
        message,
        isPinned,
        postId,
      ];
}
