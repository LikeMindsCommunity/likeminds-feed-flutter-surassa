part of 'deep_link_handler.dart';

class LMFeedDeepLinkRequest {
  LMFeedDeepLinkPath path;
  Map<String, dynamic>? data;
  String userId;
  String userName;

  LMFeedDeepLinkRequest._({
    required this.path,
    this.data,
    required this.userId,
    required this.userName,
  });

}

class LMFeedDeepLinkRequestBuilder {
  LMFeedDeepLinkPath? _path;
  Map<String, dynamic>? _data;
  String? _userId;
  String? _userName;

  void path(LMFeedDeepLinkPath path) => _path = path;
  void data(Map<String, dynamic> data) => _data = data;
  void userId(String userId) => _userId = userId;
  void userName(String userName) => _userName = userName;

  LMFeedDeepLinkRequest build() {
    return LMFeedDeepLinkRequest._(
      path: _path!,
      data: _data,
      userId: _userId!,
      userName: _userName!,
    );
  }
}