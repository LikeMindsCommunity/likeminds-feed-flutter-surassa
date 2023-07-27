import 'package:likeminds_feed/likeminds_feed.dart';

/// This class is used to implement the [LMSDKCallback] interface
class LikeMindsCallback implements LMSDKCallback {
  LikeMindsCallback();

  /// This method is called when an analytics event is fired from the SDK
  /// [eventKey] is the key of the event
  /// [propertiesMap] is the map of properties associated with the event
  @override
  void eventFiredCallback(String eventKey, Map<String, dynamic> propertiesMap) {
    print("Main event fired callback in UI: $eventKey");
    propertiesMap.forEach((key, value) {
      print("Key: $key, Value: $value");
    });
  }

  /// This method is called when the user is not logged in or guest
  /// It is called when the user tries to perform an action that requires login
  /// The user should be redirected to your appropriate login screen
  @override
  void loginRequiredCallback() {
    // TODO: implement loginRequiredCallback
  }

  /// This method is called when the user logs out
  /// The user should be redirected to your appropriate logout/login screen
  /// The user should be logged out of your app
  @override
  void logoutCallback() {
    // TODO: implement logoutCallback
  }

  @override
  void profileRouteCallback({required String lmUserId}) {
    print("LM User ID caught in callback : $lmUserId");
  }
}
