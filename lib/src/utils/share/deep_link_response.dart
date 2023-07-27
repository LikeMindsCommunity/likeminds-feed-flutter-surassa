part of 'share_post.dart';

class DeepLinkResponse {
  bool success;
  String? errorMessage;
  String? postId;

  DeepLinkResponse({
    required this.success,
    this.errorMessage,
    this.postId,
  });

  DeepLinkResponse fromJson(Map<String, dynamic> json) => DeepLinkResponse(
        success: json['success'] as bool,
        errorMessage: json['error_message'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'errorMessage': errorMessage,
      };
}
