import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/services/service_locator.dart';

part 'toggle_like_comment_event.dart';
part 'toggle_like_comment_state.dart';

class ToggleLikeCommentBloc
    extends Bloc<ToggleLikeCommentEvent, ToggleLikeCommentState> {
  final LikeMindsService lmService = locator<LikeMindsService>();

  ToggleLikeCommentBloc() : super(ToggleLikeCommentInitial()) {
    on<ToggleLikeComment>((event, emit) async {
      await _mapToggleLikeCommentToState(
        toggleLikeCommentRequest: event.toggleLikeCommentRequest,
        emit: emit,
      );
    });
  }

  Future<void> _mapToggleLikeCommentToState(
      {required ToggleLikeCommentRequest toggleLikeCommentRequest,
      required Emitter<ToggleLikeCommentState> emit}) async {
    emit(ToggleLikeCommentLoading());
    ToggleLikeCommentResponse? response =
        await lmService.toggleLikeComment(toggleLikeCommentRequest);
    if (!response.success) {
      emit(const ToggleLikeCommentError(message: "No data found"));
    } else {
      emit(ToggleLikeCommentSuccess(toggleLikeCommentResponse: response));
    }
  }
}
