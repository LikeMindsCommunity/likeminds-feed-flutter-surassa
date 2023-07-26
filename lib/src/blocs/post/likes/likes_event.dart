part of 'likes_bloc.dart';

abstract class LikesEvent extends Equatable {
  const LikesEvent();

  @override
  List<Object> get props => [];
}

class GetLikes extends LikesEvent {
  final int offset;
  final int pageSize;
  final String postId;
  const GetLikes({
    required this.offset,
    required this.pageSize,
    required this.postId,
  });

  @override
  List<Object> get props => [offset, pageSize];
}

class GetCommentLikes extends LikesEvent {
  final int offset;
  final int pageSize;
  final String postId;
  final String commentId;
  const GetCommentLikes({
    required this.offset,
    required this.pageSize,
    required this.postId,
    required this.commentId,
  });

  @override
  List<Object> get props => [offset, pageSize];
}
