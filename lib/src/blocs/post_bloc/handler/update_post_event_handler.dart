part of '../post_bloc.dart';

updatePostEventHandler(UpdatePost event, Emitter<LMPostState> emit) async {
  emit(
    PostUpdateState(post: event.post),
  );
}
