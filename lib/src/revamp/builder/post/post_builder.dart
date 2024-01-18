import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/src/revamp/builder/post/components/post_footer.dart';

Widget suraasaPostBuilder(BuildContext context, LMFeedPostWidget postWidget,
    LMPostViewData postData) {
  return postWidget.copyWith(
    footerBuilder: suraasaPostFooterBuilder,
  );
}
