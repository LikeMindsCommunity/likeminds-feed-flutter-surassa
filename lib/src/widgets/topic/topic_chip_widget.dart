import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class TopicChipWidget extends StatelessWidget {
  final TopicUI postTopic;
  const TopicChipWidget({Key? key, required this.postTopic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 8.0),
            child: LMTopicChip(
              topic: postTopic,
              backgroundColor: kPrimaryColorLight,
              borderRadius: 43,
              textStyle: const TextStyle(
                color: kPrimaryColor,
                fontSize: kFontSmallMed,
                fontWeight: FontWeight.w500,
                height: 1.30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
