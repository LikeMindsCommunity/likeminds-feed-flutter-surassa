part of 'deep_link_handler.dart';

class LMFeedDeepLinkResponse {
  bool success;
  String? errorMessage;

  LMFeedDeepLinkResponse({
    required this.success,
    this.errorMessage,
  });

  @override
  String toString() =>
      'LMFeedDeepLinkResponse(success: $success, message: $errorMessage)';
}
