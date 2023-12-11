import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/new_post_screen.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';

part 'deep_link_path.dart';
part 'deep_link_request.dart';
part 'deep_link_response.dart';

class LMFeedDeepLinkHandler {
  Future<LMFeedDeepLinkResponse> parseDeepLink(
    LMFeedDeepLinkRequest request,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    switch (request.path) {
      case LMFeedDeepLinkPath.OPEN_POST:
        return handleOpenPostDeepLink(request, navigatorKey);
      case LMFeedDeepLinkPath.CREATE_POST:
        return handleCreatePostDeepLink(request, navigatorKey);
      case LMFeedDeepLinkPath.OPEN_COMMENT:
        return handleOpenCommentDeepLink(request, navigatorKey);
      default:
        return LMFeedDeepLinkResponse(
          success: false,
          errorMessage: 'Invalid path',
        );
    }
  }

  Future<LMFeedDeepLinkResponse> handleOpenPostDeepLink(
    LMFeedDeepLinkRequest request,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    final String? postId = request.data?['post_id'];
    if (request.data == null || postId == null) {
      return LMFeedDeepLinkResponse(
        success: false,
        errorMessage: 'Invalid request, post id should not be null',
      );
    } else {
      InitiateUserResponse response =
          await locator<LMFeedBloc>().initiateUser((InitiateUserRequestBuilder()
                ..userId(request.userId)
                ..userName(request.userName))
              .build());
      if (response.success) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: postId),
          ),
        );
        return LMFeedDeepLinkResponse(
          success: true,
        );
      } else {
        return LMFeedDeepLinkResponse(
          success: false,
          errorMessage: "URI parsing failed. Please try after some time.",
        );
      }
    }
  }

  Future<LMFeedDeepLinkResponse> handleCreatePostDeepLink(
    LMFeedDeepLinkRequest request,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    InitiateUserResponse response =
        await locator<LMFeedBloc>().initiateUser((InitiateUserRequestBuilder()
              ..userId(request.userId)
              ..userName(request.userName))
            .build());
    if (response.success) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const NewPostScreen(),
        ),
      );
      return LMFeedDeepLinkResponse(
        success: true,
      );
    } else {
      return LMFeedDeepLinkResponse(
        success: false,
        errorMessage: "URI parsing failed. Please try after some time.",
      );
    }
  }

  Future<LMFeedDeepLinkResponse> handleOpenCommentDeepLink(
    LMFeedDeepLinkRequest request,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    final String? postId = request.data?['post_id'];
    final String? commentId = request.data?['comment_id'];
    if (request.data == null || postId == null || commentId == null) {
      return LMFeedDeepLinkResponse(
        success: false,
        errorMessage:
            'Invalid request, post id and comment id should not be null',
      );
    } else {
      InitiateUserResponse response =
          await locator<LMFeedBloc>().initiateUser((InitiateUserRequestBuilder()
                ..userId(request.userId)
                ..userName(request.userName))
              .build());
      if (response.success) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) =>
                PostDetailScreen(postId: request.data!['post_id']),
          ),
        );
        return LMFeedDeepLinkResponse(
          success: true,
        );
      } else {
        return LMFeedDeepLinkResponse(
          success: false,
          errorMessage: "URI parsing failed. Please try after some time.",
        );
      }
    }
  }
}
