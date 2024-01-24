import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';

Widget suraasaPostTopicChipBuilder(BuildContext context,
    LMFeedPostTopic oldTopicChip, LMPostViewData postViewData) {
  return oldTopicChip.copyWith(
    style: LMFeedPostTopicStyle.basic().copyWith(
      padding: EdgeInsets.zero,
      activeChipStyle: LMFeedTopicChipStyle.active().copyWith(
        backgroundColor: interactive100,
        textStyle: const TextStyle(color: kPrimaryColor, fontFamily: 'Inter'),
        borderRadius: BorderRadius.circular(43.0),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      ),
    ),
  );
}
