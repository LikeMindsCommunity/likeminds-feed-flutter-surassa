part of 'new_post_bloc.dart';

abstract class NewPostEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class CreateNewPost extends NewPostEvents {
  final List<MediaModel>? postMedia;
  final String postText;

  CreateNewPost({
    this.postMedia,
    required this.postText,
  });
}

class EditPost extends NewPostEvents {
  final List<Attachment>? attachments;
  final String postText;
  final String postId;

  EditPost({
    required this.postText,
    this.attachments,
    required this.postId,
  });
}

class DeletePost extends NewPostEvents {
  final String postId;
  final String reason;
  final int? feedRoomId;

  DeletePost({
    required this.postId,
    required this.reason,
    this.feedRoomId,
  });

  @override
  List<Object> get props => [postId, reason];
}

class UpdatePost extends NewPostEvents {
  final String postId;

  UpdatePost({
    required this.postId,
  });

  @override
  List<Object> get props => [postId];
}
