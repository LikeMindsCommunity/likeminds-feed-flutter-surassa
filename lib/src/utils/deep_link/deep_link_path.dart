part of 'deep_link_handler.dart';

enum LMFeedDeepLinkPath { OPEN_POST, CREATE_POST, OPEN_COMMENT }

String getLMFeedDeepLinkPath(LMFeedDeepLinkPath path) {
  switch (path) {
    case LMFeedDeepLinkPath.OPEN_POST:
      return 'OPEN_POST';
    case LMFeedDeepLinkPath.CREATE_POST:
      return 'CREATE_POST';
    case LMFeedDeepLinkPath.OPEN_COMMENT:
      return 'OPEN_COMMENT';
    default:
      return '';
  }
}

LMFeedDeepLinkPath? getLMFeedDeepLinkPathFromString(String path) {
  switch (path) {
    case 'OPEN_POST':
      return LMFeedDeepLinkPath.OPEN_POST;
    case 'CREATE_POST':
      return LMFeedDeepLinkPath.CREATE_POST;
    case 'OPEN_COMMENT':
      return LMFeedDeepLinkPath.OPEN_COMMENT;
    default:
      return null;
  }
}
