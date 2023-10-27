part of 'share_post.dart';

class DeepLinkRequest {
  String link;
  String userName;
  String userUniqueId;
  bool isGuest;
  String apiKey;
  int? feedRoomId;
  LMSDKCallback? callback;

  DeepLinkRequest._({
    required this.isGuest,
    required this.userName,
    required this.userUniqueId,
    required this.apiKey,
    required this.link,
    this.callback,
    this.feedRoomId,
  });

  toJson() => {
        'link': link,
        'user_name': userName,
        'user_unique_id': userUniqueId,
        'is_guest': isGuest,
        'x-api-key': apiKey,
      };
}

class DeepLinkRequestBuilder {
  String? _link;
  String? _userName;
  String? _userUniqueId;
  bool? _isGuest;
  String? _apiKey;
  LMSDKCallback? _callback;
  int? _feedRoomId;

  void link(String link) => _link = link;
  void userName(String userName) => _userName = userName;
  void userUniqueId(String userUniqueId) => _userUniqueId = userUniqueId;
  void isGuest(bool isGuest) => _isGuest = isGuest;
  void apiKey(String apiKey) => _apiKey = apiKey;
  void callback(LMSDKCallback? callback) => _callback = callback;
  void feedRoomId(int feedRoomId) => _feedRoomId = feedRoomId;

  DeepLinkRequest build() {
    return DeepLinkRequest._(
      link: _link!,
      isGuest: _isGuest!,
      userName: _userName!,
      userUniqueId: _userUniqueId!,
      apiKey: _apiKey!,
      callback: _callback,
      feedRoomId: _feedRoomId,
    );
  }
}
