import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/utils/credentials/credentials.dart';
import 'package:likeminds_feed_ss_fl/src/views/post_detail_screen.dart';
import 'package:share_plus/share_plus.dart';
part 'deep_link_request.dart';
part 'deep_link_response.dart';

class SharePost {
  static String userId = prodFlag ? CredsProd.botId : CredsDev.botId;
  static String apiKey = prodFlag ? CredsProd.apiKey : CredsDev.apiKey;
  // TODO: Add domain to your application
  String domain = 'https://www.suraasa.com';
  // fetches the domain given by client at time of initialization of Feed

  // below function creates a link from domain and post id
  String createLink(String postId) {
    int length = domain.length;
    if (domain[length - 1] == '/') {
      return "${domain}community/post?post_id=$postId";
    } else {
      return "$domain/community/post?post_id=$postId";
    }
  }

  // Below functions takes the user outside of the application
  // using the domain provided at the time of initialization
  // TODO: Add prefix text, image as per your requirements
  void sharePost(String postId) {
    String postUrl = createLink(postId);
    Share.share(postUrl);
  }

  String getFirstPathSegment(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.first;
    } else {
      return '';
    }
  }

  Future<DeepLinkResponse> handlePostDeepLink(
    DeepLinkRequest request,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    List secondPathSegment = request.link.split('post_id=');
    if (secondPathSegment.length > 1 && secondPathSegment[1] != null) {
      String postId = secondPathSegment[1];
      await locator<LMFeedClient>().initiateUser((InitiateUserRequestBuilder()
            ..apiKey(request.apiKey)
            ..userId(request.userUniqueId)
            ..userName(request.userName))
          .build());

      locator<LMFeedBloc>()
          .lmRoutingBloc
          .add(HandleSharedPostEvent(postId: postId));

      // Comment the below code if navigation is being handled by LMRoutingBloc
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(postId: postId),
        ),
      );

      return DeepLinkResponse(
        success: true,
        postId: postId,
      );
    } else {
      return DeepLinkResponse(
        success: false,
        errorMessage: 'URI not supported',
      );
    }
  }

  Future<DeepLinkResponse> parseDeepLink(
      DeepLinkRequest request, GlobalKey<NavigatorState> navigatorKey) async {
    final link = Uri.parse(request.link);
    if (link.isAbsolute) {
      if (link.path == '/community/post') {
        return handlePostDeepLink(request, navigatorKey);
      }
      return DeepLinkResponse(
          success: false, errorMessage: 'URI not supported');
    } else {
      return DeepLinkResponse(
        success: false,
        errorMessage: 'URI not supported',
      );
    }
  }
}
