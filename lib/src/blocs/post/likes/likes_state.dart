part of 'likes_bloc.dart';

abstract class LikesState extends Equatable {
  const LikesState();

  @override
  List<Object> get props => [];
}

class LikesInitial extends LikesState {}

class LikesLoading extends LikesState {}

class LikesPaginationLoading extends LikesState {}

class LikesLoaded extends LikesState {
  final GetPostLikesResponse response;
  const LikesLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class CommentLikesLoaded extends LikesState {
  final GetCommentLikesResponse response;
  const CommentLikesLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class LikesError extends LikesState {
  final String message;
  const LikesError({required this.message});

  @override
  List<Object> get props => [message];
}
