part of 'all_comments_bloc.dart';

abstract class AllCommentsEvent extends Equatable {
  const AllCommentsEvent();
}

class GetAllComments extends AllCommentsEvent {
  final PostDetailRequest postDetailRequest;
  final bool forLoadMore;
  const GetAllComments({required this.postDetailRequest, required this.forLoadMore});

  @override
  List<Object?> get props => [postDetailRequest, forLoadMore];
}
