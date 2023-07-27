// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'all_comments_bloc.dart';

abstract class AllCommentsState extends Equatable {
  const AllCommentsState();
}

class AllCommentsInitial extends AllCommentsState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AllCommentsLoaded extends AllCommentsState {
  final PostDetailResponse postDetails;
  final bool hasReachedMax;
  const AllCommentsLoaded({required this.postDetails, required this.hasReachedMax});

  @override
  List<Object?> get props => [postDetails, hasReachedMax];
}

class AllCommentsLoading extends AllCommentsState {
  @override
  List<Object?> get props => [];
}

class PaginatedAllCommentsLoading extends AllCommentsState {
  final PostDetailResponse prevPostDetails;
  const PaginatedAllCommentsLoading({
    required this.prevPostDetails,
  });
  @override
  List<Object?> get props => [];
}

class AllCommentsError extends AllCommentsState {
  final String message;
  const AllCommentsError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
